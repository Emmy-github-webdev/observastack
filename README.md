# observability with prometheus grafana loki alloy and tempo

## Monitoring
Monitoring is collecting and visualising data about systems regularly so that the system's health can be viewed and tracked.

## Telemetry Data
Telemetry data are data used to find where the problem might be.

## Metrics used to measure the DevOps Success
- Mean Time to Detection (MTTD) - is the amount of time, on average, between the start of an issue and when teams become aware of it.

- Mean Time to resolve (MTTR) - is the average ammount of time between when an issue is detected, and when systems are fixed and operating normally.

## Methods Monitoring 

Any microservices based abblication has three main layers.
1. UI Layer: web and mobile services
2. Service Layer: example - Cart, payment, promotion, and fulfilment services
3. Infrastructure layers: Memory, CPU, Network, VMs

Methods of collecting the metrics are
1. Red Method:Rate, error, and duration. This mostly cover the service and UI layers. 
2. Use Method: Utilization, saturation, error. This id for the infrastructure layer.
3. Four Golden Signals: Latency, Traffic, Errors, Saturation. This covers service layer and some extend the infrastructure layer.
4. Core Web Vitals: Largets contentful paint, first input delay, cumulative layout shift. This is exclusively for the UI layer and website.

## methods of metric collection

1. Push method: Applications and Microservices send the metrics to an endpoint via TCP, UDP, or HTTP. Example is an application sending metrics to StatsD, to be stored on Graphite.

2. Scrape method: Applications and Microservices provide APIs for the time series database, to read the metrics. Example is prometheus scraping metrics.

## Types of Telemetry Data
1. Metric
2. Event
3. Log
4. Trace
 
## Install Prometheus on Linux Ububtu

- Download the installer - https://prometheus.io/download
- change the Operating system to ubuntu and the correct architecture
- Right click the image and copy the public download url
- Use wget to download it
- Prometheus needs user and group
  - Create group - sudo groupadd --system prometheus
  - Create User and add the user to the group - sudo useradd -s /sbin/nologin --system -g prometheus prometheus
- Create directory for prometheus - sudo mkdir /var/lib/prometheus
- Create repective rules diectory
  - sudo mkdir -p /etc/prometheus/rules
  - sudo mkdir -p /etc/prometheus/rules.s
  - sudo mkdir -p /etc/prometheus/files_sd

- Unzip the installer downloaded in step 1 - sudo tar xvf installer name
- change directory to the unzip foler
- Move the prometheus and promtool folders to user bin directory - sudo mv prometheus promtool /usr/local/bin/
- Verify that the prometheus is accessible by checking the version - prometheus --version
- Move the premetheus yaml file to /etc/prometheus/ folder - sudo mv prometheus.yaml /etc/prometheus/prometheus.yaml
- Create the service file
```
sudo tee /etc/systemd/system/prometheus.service<<EOF
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.external-url=

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF>>
```

- Make prometheus user owner of all folder and file 
  - sudo chown -R prometheus:prometheus /etc/prometheus
  - sudo chown -R prometheus:prometheus /etc/prometheus/*
  - sudo chown -R 775 /etc/prometheus
  - sudo chown -R 775 /etc/prometheus/*
  - sudo chown -R prometheus:prometheus /var/lib/prometheus
  - sudo chown -R prometheus:prometheus /var/lib/prometheus/*

- Reload the daemon - sudo systemctl daemon-reload
- start the service - sudo systemctl start prometheus
- Check Prometheus status - sudo systemctl status prometheus
- Lunch the prometheus on browser - VMIP:9090

## Data Collection
Exporter is used to get metrics from a Linux server, Database, IoT, Amazon clouwatch, HAProxy by installing the exporter in the target or source of the metrics. The prometheus pull the metrics from the exporter.

### Scraping
Scraping is the process of connecting to an exporter and pulling the metrics into Prometheus is called scraping. Scraping can be configured in the prometheus config file. By default, prometheus connect to the exporters and pulls the metrics in every 15 seconds and store it in prometheus.

<br>

A push gateway is a component of prometheus which acts as temporary storage, where application can send metrics to it. It has a built in exporter. So prometheus can scrap the matrics from push gateway. Applications push metrics to push gateway and prometheus scrap the metrics from push gateway.

## Types of Exporter
1. _Node Exporter_: is an official(part of prometheus project) prometheus exporter for collecting metrics that exposed by Unix-based kernels e.g Linux and Ubuntu. Example of metrics that can be collected by Node exporter includes
  - CPU usage
  - Disk usage
  - Memmory usage
  - Network I/O

### Setup Node Exporter
_Note that you do not install node exporter on the same machine where prometheus is installed, unless you want to collect metrics from the same machine with prometheus installed_

Also consider the following configuration 
  - on Node Server
    - Security: 
      - Enable port 22 TCP. Select the sources as needed (Specific IP, all IPs, etc)
      - port 9100: Node export listens on prot 9100. Source is the security group ID of the prometheus server.
- Download node exporter installer from - https://prometheus.io/download
- Right click the installer and cpoy the download link
- Use wget to dowload the installer
- Unzip the downloaded node exporter
- change directory to the unzipped node exporter
- Run it - ./node_exporter

