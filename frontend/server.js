("use strict");

const express = require("express");
const morgan = require("morgan");
const winston = require("winston");

const PORT = process.env.port || 8080;

const logger = winston.createLogger({
  level: "info",
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: "error.log", level: "error" }),
    new winston.transports.File({ filename: "combined.log" })
  ]
});

//
if (process.env.NODE_ENV !== "production") {
  logger.add(
    new winston.transports.Console({
      format: winston.format.simple()
    })
  );
}

const app = express();
app.use(morgan("dev"));

app.use(express.static(__dirname));

app.get("*", (req, res) => {
  res.sendFile("index.html", { root: __dirname });
});

const server = app.listen(PORT, logger.info(`listening on port :${PORT}`));

var signals = {
  SIGHUP: 1,
  SIGINT: 2,
  SIGTERM: 15
};

// Do any necessary shutdown logic for our application here
const shutdown = (signal, value) => {
  server.close(() => {
    logger.info("shutting down");
    process.exit(128 + value);
  });
};

// Create a listener for each of the signals that we want to handle
Object.keys(signals).forEach(signal => {
  process.on(signal, () => {
    shutdown(signal, signals[signal]);
  });
});
