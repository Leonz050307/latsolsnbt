(function () {
    const tokenInput = () => {
        const meta = document.querySelector('meta[name="csrf"]');
        return meta ? meta.getAttribute('content') : (window.csrfToken || '');
    };

    const deviceUuidKey = 'latsol_device_uuid';
    let deviceUuid = localStorage.getItem(deviceUuidKey);
    if (!deviceUuid) {
        deviceUuid = ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c =>
            (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
        );
        localStorage.setItem(deviceUuidKey, deviceUuid);
    }

    const getDeviceHash = () => {
        const ua = navigator.userAgent;
        const ipSubnet = '0.0.0.0';
        return sha256(`${ua}|${ipSubnet}|${deviceUuid}`);
    };

    function sha256(str) {
        const encoder = new TextEncoder();
        const data = encoder.encode(str);
        return crypto.subtle.digest('SHA-256', data).then(hash => {
            const hexCodes = [];
            const view = new DataView(hash);
            for (let i = 0; i < view.byteLength; i += 4) {
                const value = view.getUint32(i);
                const stringValue = value.toString(16);
                const padding = '00000000';
                hexCodes.push((padding + stringValue).slice(-padding.length));
            }
            return hexCodes.join('');
        });
    }

    const dashboard = document.querySelector('.dashboard');
    if (dashboard) {
        const buttons = dashboard.querySelectorAll('.subtest-card .btn-primary, .subtest-card .btn-secondary');
        buttons.forEach(btn => {
            btn.addEventListener('click', async () => {
                const subtestId = btn.getAttribute('data-subtest');
                const mode = btn.getAttribute('data-mode');
                const hash = await getDeviceHash();
                const formData = new FormData();
                formData.append('subtest_id', subtestId);
                formData.append('mode', mode);
                formData.append('device_hash', hash);
                formData.append('_csrf', window.csrfToken);
                fetch('/attempt/start', {
                    method: 'POST',
                    body: formData,
                    credentials: 'include'
                })
                    .then(r => r.json())
                    .then(data => {
                        const container = document.getElementById('attempt-result');
                        if (!data.ok) {
                            container.innerHTML = `<div class="alert alert-danger">${data.data.error}</div>`;
                            return;
                        }
                        sessionStorage.setItem('currentAttempt', JSON.stringify(data.data));
                        window.location.href = '/attempt';
                    })
                    .catch(() => {
                        alert('Gagal memulai attempt');
                    });
            });
        });
        const battleButtons = dashboard.querySelectorAll('.subtest-card .battle');
        battleButtons.forEach(btn => {
            btn.addEventListener('click', async () => {
                const subtestId = btn.getAttribute('data-subtest');
                const hash = await getDeviceHash();
                const formData = new FormData();
                formData.append('subtest_id', subtestId);
                formData.append('mode', 'kejar_waktu');
                formData.append('device_hash', hash);
                formData.append('_csrf', window.csrfToken);
                fetch('/battle/join', { method: 'POST', body: formData, credentials: 'include' })
                    .then(r => r.json())
                    .then(data => {
                        alert(`Battle status: ${data.data.status}`);
                    });
            });
        });
    }

    if (window.location.pathname === '/attempt') {
        const attemptData = sessionStorage.getItem('currentAttempt');
        if (!attemptData) {
            window.location.href = '/dashboard';
            return;
        }
        const parsed = JSON.parse(attemptData);
        window.currentAttempt = parsed;
        const questionContainer = document.getElementById('question-container');
        const timerDisplay = document.getElementById('timer-display');
        let index = 0;
        const responses = {};
        const renderQuestion = () => {
            const q = parsed.questions[index];
            document.getElementById('attempt-title').textContent = `Soal ${index + 1}/5`;
            questionContainer.innerHTML = `
                <div class="question">
                    <p>${q.stem}</p>
                    <div class="choices">
                        ${Object.entries(q.choices).map(([label, content]) => `
                            <button class="choice" data-label="${label}">${label}. ${content}</button>
                        `).join('')}
                    </div>
                </div>
            `;
            questionContainer.querySelectorAll('.choice').forEach(choiceBtn => {
                choiceBtn.addEventListener('click', async () => {
                    const label = choiceBtn.getAttribute('data-label');
                    responses[q.id] = label;
                    const formData = new FormData();
                    formData.append('attempt_id', parsed.attempt_id);
                    formData.append('question_id', q.id);
                    formData.append('choice', label);
                    formData.append('_csrf', window.csrfToken);
                    fetch('/attempt/answer', { method: 'POST', body: formData, credentials: 'include' });
                    renderQuestion();
                });
                if (responses[q.id] === choiceBtn.getAttribute('data-label')) {
                    choiceBtn.classList.add('selected');
                }
            });
        };
        document.getElementById('next-question').addEventListener('click', () => {
            index = (index + 1) % parsed.questions.length;
            renderQuestion();
        });
        document.getElementById('prev-question').addEventListener('click', () => {
            index = (index - 1 + parsed.questions.length) % parsed.questions.length;
            renderQuestion();
        });
        document.getElementById('submit-attempt').addEventListener('click', () => {
            const formData = new FormData();
            formData.append('attempt_id', parsed.attempt_id);
            formData.append('_csrf', window.csrfToken);
            fetch('/attempt/submit', { method: 'POST', body: formData, credentials: 'include' })
                .then(r => r.json())
                .then(data => {
                    if (data.ok) {
                        alert(`Skor kamu ${data.data.score}`);
                        sessionStorage.removeItem('currentAttempt');
                        window.location.href = '/dashboard';
                    }
                });
        });
        renderQuestion();
        const modeTimers = { kejar_waktu: 420, santai: 1200 };
        let remaining = modeTimers[parsed.mode] || 420;
        const tick = () => {
            const minutes = Math.floor(remaining / 60).toString().padStart(2, '0');
            const seconds = (remaining % 60).toString().padStart(2, '0');
            timerDisplay.textContent = `${minutes}:${seconds}`;
            if (remaining <= 0) {
                document.getElementById('submit-attempt').click();
            } else {
                remaining -= 1;
                setTimeout(tick, 1000);
            }
        };
        tick();
        let blurCount = 0;
        document.addEventListener('visibilitychange', () => {
            if (document.hidden) {
                blurCount += 1;
                if (blurCount > 3) {
                    alert('Terlalu sering berganti tab! Attempt akan dikunci.');
                }
            }
        });
    }

    if (document.querySelector('.scoreboard')) {
        const subtestSelect = document.getElementById('filter-subtest');
        const modeSelect = document.getElementById('filter-mode');
        const dateInput = document.getElementById('filter-date');
        const tbody = document.getElementById('scoreboard-body');
        const renderRows = (rows) => {
            tbody.innerHTML = rows.map((row, idx) => `
                <tr>
                    <td>${idx + 1}</td>
                    <td>${row.username}</td>
                    <td>${row.score}</td>
                    <td>${row.duration_seconds ?? '-'}</td>
                </tr>
            `).join('');
        };
        const fetchBoard = () => {
            const url = `/api/scoreboard?subtest_id=${subtestSelect.value}&mode=${modeSelect.value}&date=${dateInput.value}`;
            fetch(url, { credentials: 'include' })
                .then(r => r.json())
                .then(data => {
                    if (data.ok) {
                        renderRows(data.data.top || []);
                    }
                });
        };
        [subtestSelect, modeSelect, dateInput].forEach(el => el.addEventListener('change', fetchBoard));
        if (!!window.EventSource) {
            const url = `/sse/scoreboard?subtest_id=${subtestSelect.value}&mode=${modeSelect.value}&date=${dateInput.value}`;
            const source = new EventSource(url);
            source.onmessage = (event) => {
                const payload = JSON.parse(event.data);
                renderRows(payload.top || []);
            };
        } else {
            setInterval(fetchBoard, 5000);
        }
        fetchBoard();
    }
})();
