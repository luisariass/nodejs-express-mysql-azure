module.exports = {
  HOST: process.env.DB_HOST || "20.73.7.112",
  USER: process.env.DB_USER || "dbuser",
  PASSWORD: process.env.DB_PASSWORD || "123456",
  DB: process.env.DB_NAME || "testdb",
  PORT: process.env.DB_PORT || 3306
};