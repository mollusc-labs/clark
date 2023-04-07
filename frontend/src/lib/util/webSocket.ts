export const latestLogWebSocket =
    new WebSocket('ws://' + (import.meta.env.PROD ? window.location.host : 'localhost:3000') + '/ws/logs/latest', 'echo-protocol')