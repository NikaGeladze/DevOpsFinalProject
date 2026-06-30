const SERVICE_NAME = process.env.SERVICE_NAME || "demo-app";

function log(level, message, extra = {}) {
  const entry = {
    timestamp: new Date().toISOString().slice(0, 19),
    level,
    service: SERVICE_NAME,
    message,
    logger: SERVICE_NAME,
    ...extra,
  };
  process.stdout.write(`${JSON.stringify(entry)}\n`);
}

module.exports = {
  info: (message, extra) => log("INFO", message, extra),
  error: (message, extra) => log("ERROR", message, extra),
  warn: (message, extra) => log("WARN", message, extra),
};
