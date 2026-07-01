const data = require('fs').readFileSync(0, 'utf8');
const lines = data.split('\n');
let idx = 0;
const next = () => lines[idx++];

