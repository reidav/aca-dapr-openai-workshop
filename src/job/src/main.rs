use std::{collections::HashMap, thread, time::Duration};
use chrono::Utc;
use serde_json::json;
use url::Url;
use uuid::Uuid;

fn get_requestor_urls() -> Result<Vec<Url>, Box<dyn std::error::Error>> {
    let mut urls: Vec<Url> = Vec::new();
    let job_urls: String = std::env::var("JOB_REQUESTED_URLS")?.parse()?;
    let job_urls_parts = job_urls.split(",");

    for url in job_urls_parts {
        urls.push(Url::parse(&url)?);
        println!("[INFO] requested link '{}' provided", url);
    }

    Ok(urls)
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    
    // Retrieve environment variables
    let urls = get_requestor_urls().expect("Unable to get urls");
    let requestor_email = std::env::var("JOB_REQUESTOR_EMAIL")?;
    let pubsub_name = std::env::var("PUBSUB_REQUESTS_NAME")?;
    let topic = std::env::var("PUBSUB_REQUESTS_TOPIC")?;

    // Introduce delay so that dapr grpc port is assigned before app tries to connect
    thread::sleep(Duration::from_secs(2));

    // Get the Dapr port and create a connection
    let port: u16 = std::env::var("DAPR_GRPC_PORT")?.parse()?;
    let addr = format!("https://127.0.0.1:{}", port);
    println!("[INFO] Using dapr grpc endpoint {}", addr);

    let mut client = dapr::Client::<dapr::client::TonicClient>::connect(addr).await?;
    let data_content_type = "application/json".to_string();

    for url in urls {        

        // Message CloudEvent metadata
        let mut metadata = HashMap::<String, String>::new();
        metadata.insert("specversion".to_string(), "1.0".to_string());
        metadata.insert("id".to_string(), Uuid::new_v4().to_string());
        metadata.insert("time".to_string(), Utc::now().to_string());
        metadata.insert("source".to_string(), "bulk-url-requestor".to_string());
        
        // Message CloudEvent data
        let message = json!({
            "url": "https://learn.microsoft.com/en-us/azure/container-apps/overview".to_string(),
            "email": "me@loadtesting.io"
        });

        println!("[INFO] Sending Url Summarization Request Event for {} owned by {}", &url, &requestor_email);

        client
            .publish_event(
                &pubsub_name,
                &topic,
                &data_content_type,
                message.to_string().into_bytes(),
                Some(metadata),
            )
            .await?;

        // sleep for 2 secs to simulate delay b/w two events
        tokio::time::sleep(Duration::from_secs(2)).await;
    };

    Ok(())
}