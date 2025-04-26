// const express = require("express"); // Importa el módulo Express para crear aplicaciones web.
// const cors = require("cors"); // Importa el módulo CORS para manejar solicitudes de diferentes orígenes.

// const app = express(); // Crea una instancia de la aplicación Express.

// var corsOptions = {
//   origin: "http://localhost:8081" // Define las opciones de CORS, permitiendo solicitudes desde este origen específico.
// };

app.use(cors()); // Configura la aplicación para usar CORS.

// parse requests of content-type - application/json
// app.use(express.json()); // Middleware para analizar solicitudes con cuerpo en formato JSON.

// parse requests of content-type - application/x-www-form-urlencoded
// app.use(express.urlencoded({ extended: true })); // Middleware para analizar solicitudes con datos codificados en URL.

// simple route
// app.get("/", (req, res) => {
//   res.json({ message: "Welcome to bezkoder application." }); // Define una ruta simple que responde con un mensaje JSON.
// });

// require("./app/routes/tutorial.routes.js")(app); // Importa y configura las rutas del archivo tutorial.routes.js.

// set port, listen for requests
// const PORT = process.env.PORT || 8080; // Define el puerto en el que el servidor escuchará, usando una variable de entorno o el puerto 8080 por defecto.
// app.listen(PORT, () => {
//   console.log(`Server is running on port ${PORT}.`); // Inicia el servidor y muestra un mensaje en la consola indicando el puerto.
// });
