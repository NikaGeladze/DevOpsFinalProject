const app = require("./app");
const logger = require("./logger");

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  logger.info(`Starting demo-app on port ${PORT}`, { port: PORT });
});
