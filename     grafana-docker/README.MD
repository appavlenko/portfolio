# Monitoring Setup with Prometheus and Grafana

This project demonstrates how to set up a monitoring solution using Prometheus and Grafana. Prometheus is used for collecting metrics from various services, and Grafana is used for visualizing these metrics on custom dashboards.

## Prerequisites

- Docker and Docker Compose installed on your system.

## Files

- **docker-compose.yml**: Docker Compose configuration to start Prometheus, Grafana, and Node Exporter.
- **prometheus/prometheus.yml**: Prometheus configuration file that defines targets for scraping metrics.
- **prometheus/rules.yml**: Alerting rules for Prometheus.
- **grafana/datasources/datasource.yml**: Configuration for Prometheus as a datasource in Grafana.
- **grafana/dashboards/dashboard.json**: Example Grafana dashboard configuration.
- **grafana/provisioning/dashboards.yml**: Configuration for automatically loading dashboards in Grafana.
- **grafana/provisioning/datasources.yml**: Configuration for automatically loading datasources in Grafana.

## Usage

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-repo/monitoring-setup.git
   cd monitoring-setup
2. **Start the monitoring stack**:
   ```bash
    docker-compose up -d

3. **Access Grafana**:
  Open your browser and navigate to http://localhost:3000.
  Log in with admin as both username and password (you can change this in the environment variables).

4. **Explore Prometheus**:
   Prometheus will be available at http://localhost:9090

5. **View dashboards**:
Grafana dashboards will be automatically provisioned. You can create or modify dashboards to fit your needs.
