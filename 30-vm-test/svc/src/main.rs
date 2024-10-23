use axum::{
    routing::{get, post},
    Router,
    extract::Json,
};


#[tokio::main]
async fn main() {
    // build our application with a single route
    let app = Router::new().route("/", get(|| async { "Hello, World!" }))
    .route("/echo", post(echo));

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn echo(Json(params): Json<serde_json::Value>) -> Json<serde_json::Value> {
    Json(params)
}
