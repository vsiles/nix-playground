use axum::{
    extract::Json,
    routing::{get, post},
    Router,
};

#[tokio::main]
async fn main() {
    println!("Hello");

    let app = Router::new()
        .route("/", get(hello))
        .route("/echo", post(echo));

    println!("Listening on port 3000");
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn hello() -> String {
    "Hello, You!".to_string()
}

async fn echo(Json(params): Json<serde_json::Value>) -> Json<serde_json::Value> {
    println!("Echo, got: {params:#?}");
    Json(params)
}
