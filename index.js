const app = require("express")();
const http = require("http").createServer(app);

app.get("/", (req, res) => {
  res.send("Node server is running now ...");
});

const socketio = require("socket.io")(http, {});

socketio.on("connection", (userSocket) => {
  userSocket.on("send_message", (data) => {
    // userSocket.broadcast.emit("receive_message", data);
    console.log("data masuk", data);
    socketio.emit("receive_message", data);
  });
});

http.listen(process.env.PORT, () => {
  console.log("App runing on port", process.env.PORT);
});
