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
- Move the premetheus yml file to /etc/prometheus/ folder - sudo mv prometheus.yml /etc/prometheus/prometheus.yml
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

### Using UserData for EC2
```
#!/bin/bash

set -e

# ============================================================
# Prometheus installation
# ============================================================

PROMETHEUS_VERSION="3.14.0-rc.0"
PROMETHEUS_URL="https://github.com/prometheus/prometheus/releases/download/v3.14.0-rc.0/prometheus-3.14.0-rc.0.linux-amd64.tar.gz"

INSTALL_DIR="/tmp/prometheus-install"
PROMETHEUS_DIR="/etc/prometheus"
DATA_DIR="/var/lib/prometheus"

echo "Starting Prometheus installation..."

# ------------------------------------------------------------
# Install required packages
# ------------------------------------------------------------

apt-get update
apt-get install -y wget tar

# ------------------------------------------------------------
# Create Prometheus group and user
# ------------------------------------------------------------

if ! getent group prometheus > /dev/null; then
    groupadd --system prometheus
fi

if ! id prometheus > /dev/null 2>&1; then
    useradd \
        --system \
        --no-create-home \
        --shell /usr/sbin/nologin \
        --gid prometheus \
        prometheus
fi

# ------------------------------------------------------------
# Create directories
# ------------------------------------------------------------

mkdir -p "$INSTALL_DIR"
mkdir -p "$PROMETHEUS_DIR"
mkdir -p "$PROMETHEUS_DIR/rules"
mkdir -p "$PROMETHEUS_DIR/rules.d"
mkdir -p "$PROMETHEUS_DIR/files_sd"
mkdir -p "$DATA_DIR"

# ------------------------------------------------------------
# Download Prometheus
# ------------------------------------------------------------

echo "Downloading Prometheus..."

wget -O "$INSTALL_DIR/prometheus.tar.gz" "$PROMETHEUS_URL"

# ------------------------------------------------------------
# Extract Prometheus
# ------------------------------------------------------------

echo "Extracting Prometheus..."

tar -xvf "$INSTALL_DIR/prometheus.tar.gz" -C "$INSTALL_DIR"

EXTRACTED_DIR=$(find "$INSTALL_DIR" -maxdepth 1 -type d -name "prometheus-*" | head -n 1)

if [ -z "$EXTRACTED_DIR" ]; then
    echo "ERROR: Prometheus extraction directory not found."
    exit 1
fi

# ------------------------------------------------------------
# Install Prometheus binaries
# ------------------------------------------------------------

echo "Installing Prometheus binaries..."

install -m 0755 "$EXTRACTED_DIR/prometheus" /usr/local/bin/prometheus
install -m 0755 "$EXTRACTED_DIR/promtool" /usr/local/bin/promtool

# ------------------------------------------------------------
# Install Prometheus configuration and console files
# ------------------------------------------------------------

echo "Installing Prometheus configuration..."

cp "$EXTRACTED_DIR/prometheus.yml" "$PROMETHEUS_DIR/prometheus.yml"

if [ -d "$EXTRACTED_DIR/consoles" ]; then
    cp -r "$EXTRACTED_DIR/consoles" "$PROMETHEUS_DIR/"
fi

if [ -d "$EXTRACTED_DIR/console_libraries" ]; then
    cp -r "$EXTRACTED_DIR/console_libraries" "$PROMETHEUS_DIR/"
fi

# ------------------------------------------------------------
# Set ownership
# ------------------------------------------------------------

echo "Setting permissions..."

chown -R prometheus:prometheus "$PROMETHEUS_DIR"
chown -R prometheus:prometheus "$DATA_DIR"

chmod 755 "$PROMETHEUS_DIR"
chmod 755 "$DATA_DIR"

# ------------------------------------------------------------
# Create systemd service
# ------------------------------------------------------------

echo "Creating Prometheus systemd service..."

cat > /etc/systemd/system/prometheus.service <<'EOF'
[Unit]
Description=Prometheus Monitoring System
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus

ExecReload=/bin/kill -HUP \$MAINPID

ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090

Restart=always
RestartSec=5

SyslogIdentifier=prometheus

[Install]
WantedBy=multi-user.target
EOF

# ------------------------------------------------------------
# Reload systemd
# ------------------------------------------------------------

systemctl daemon-reload

# ------------------------------------------------------------
# Enable and start Prometheus
# ------------------------------------------------------------

systemctl enable prometheus
systemctl start prometheus

# ------------------------------------------------------------
# Verify installation
# ------------------------------------------------------------

echo "Prometheus version:"
/usr/local/bin/prometheus --version

echo ""
echo "Prometheus service status:"
systemctl --no-pager status prometheus

echo ""
echo "Prometheus installation completed successfully."
```
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

### Using UserData
```
#!/bin/bash

set -e

# ============================================================
# Node Exporter installation
# ============================================================

NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v1.12.1/node_exporter-1.12.1.linux-amd64.tar.gz"

INSTALL_DIR="/tmp/node-exporter-install"

echo "Starting Node Exporter installation..."

# ------------------------------------------------------------
# Install required packages
# ------------------------------------------------------------

apt-get update
apt-get install -y wget tar

# ------------------------------------------------------------
# Create Node Exporter user
# ------------------------------------------------------------

if ! id node_exporter > /dev/null 2>&1; then
    useradd \
        --system \
        --no-create-home \
        --shell /usr/sbin/nologin \
        node_exporter
fi

# ------------------------------------------------------------
# Create temporary installation directory
# ------------------------------------------------------------

mkdir -p "$INSTALL_DIR"

# ------------------------------------------------------------
# Download Node Exporter
# ------------------------------------------------------------

echo "Downloading Node Exporter..."

wget -O "$INSTALL_DIR/node_exporter.tar.gz" "$NODE_EXPORTER_URL"

# ------------------------------------------------------------
# Extract Node Exporter
# ------------------------------------------------------------

echo "Extracting Node Exporter..."

tar -xvf "$INSTALL_DIR/node_exporter.tar.gz" -C "$INSTALL_DIR"

EXTRACTED_DIR=$(find "$INSTALL_DIR" -maxdepth 1 -type d -name "node_exporter-*" | head -n 1)

if [ -z "$EXTRACTED_DIR" ]; then
    echo "ERROR: Node Exporter extraction directory not found."
    exit 1
fi

# ------------------------------------------------------------
# Install Node Exporter binary
# ------------------------------------------------------------

echo "Installing Node Exporter..."

install -m 0755 \
    "$EXTRACTED_DIR/node_exporter" \
    /usr/local/bin/node_exporter

chown node_exporter:node_exporter /usr/local/bin/node_exporter

# ------------------------------------------------------------
# Create systemd service
# ------------------------------------------------------------

echo "Creating Node Exporter systemd service..."

cat > /etc/systemd/system/node_exporter.service <<'EOF'
[Unit]
Description=Node Exporter
Documentation=https://prometheus.io/docs/guides/node-exporter/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=node_exporter
Group=node_exporter

ExecStart=/usr/local/bin/node_exporter

Restart=always
RestartSec=5

SyslogIdentifier=node_exporter

[Install]
WantedBy=multi-user.target
EOF

# ------------------------------------------------------------
# Reload systemd
# ------------------------------------------------------------

systemctl daemon-reload

# ------------------------------------------------------------
# Enable and start Node Exporter
# ------------------------------------------------------------

systemctl enable node_exporter
systemctl start node_exporter

# ------------------------------------------------------------
# Verify installation
# ------------------------------------------------------------

echo ""
echo "Node Exporter version:"
/usr/local/bin/node_exporter --version

echo ""
echo "Node Exporter service status:"
systemctl --no-pager status node_exporter

echo ""
echo "Node Exporter installation completed successfully."
```

## Configure Prometheus to scrape metrics from application server
- Lunch the prometheus server
- Note that my yml file location is - /etc/prometheus/prometheus.yml
- Update the prometheus.yml with the node exporter installed. Each time you have node exporter install, you have to do this. 
  - _sudo vim prometheus.yml_
  - Go inside the scrape_configs:
  - Add the job below

  ```
  - job_name: 'application_server'
    static_configs:
    - targets: ['node_exporter_server_private_or_public_ip:9100'] # Depending if they are on the same or different network.
  ```
  - Save the config file
- Restart prometheus: 
  - sudo systemctl stop prometheus
  - sudo systemctl start prometheus
- Relunch your prometheus on browser
- Click on the status and you should see target server/endpoint

## Run node exporter as a service

In the above section, we have to start the node exporter and if the terminal is closed, the node exporter will stop. In order to keep running, we have to run it as a service.

- Create group - sudo groupadd --system prometheus
- Create User and add the user to the group - sudo useradd -s /sbin/nologin --system -g prometheus prometheus
- Create a note file - _sudo mkdir -p /var/lib/node_
- Move the node_exporter (from the unzipped node_exporter downloaded earlier) folder to /var/lib/node_
- Update the service file
  - open the service file: sudo vim /etc/systemd/system/node.service
  - add the content below

```
[Unit]
Description=Prometheus Node Exporter
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/var/lib/node/node_exporter

SyslogIdentifier=prometheus_node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
```
- Save the file
- Make the user owner of the node folder/files: 
  - sudo chown -R prometheus:prometheus /var/lib/node
  - sudo chown -R prometheus:prometheus /var/lib/node/*
- Provide the use read amd write access
  - sudo chmod -R 775 /var/lib/node
  - sudo chmod -R 775 /var/lib/node/*
- Reload the system daemon: sudo systemctl daemon-reload
- Enable node service: sudo systemctl enable node
- Start the node service: sudo systemctl start node
- Check the status: sudo systemctl status node

## Data Model
In Prometheus, data is storedas time series, which means that we have a metric and there is a timestamp, a linux timestamp attached to it. 

### Types of Data Types
- Scalar - float, string
  _Store sample_
  ```
  prometheus_http_requests_total{code="200", job="prometheus"}
  ```
  _Query sample_
  ```
  prometheus_http_requests_total{code=~"2.*", job="prometheus"}
  ```

- Instant vector - selects a set of time series and a single sample value for any timestap. Meaning, only a metric name is specified

- Range Vector - Similar to range vectors except they select a range of samples.

- Example
  - Open metric from node exporter in another tab of your browser
  - Pick one metrics, e.g _node_network_transmit_err_total_
  - Go to the prometheus and search it. It should show metrics.
  - To apply a range:  _node_network_transmit_err_total[5m]_

## Aggregation Operators
Try the following in prometheus
- node_cpu_seconds_total
- sum - sum(node_cpu_seconds_total)
- sum by - sum(node_cpu_seconds_total) by (mode)
- Sum without - sum(node_cpu_seconds_total) without (mode)
- topk (Top largest value) - topk{3, sum(node_cpu_seconds_total) without (mode)}
- bottomk (Bottom lowest value) - bottomk{3, sum(node_cpu_seconds_total) without (mode)}
- group - group(node_cpu_seconds_total)
- group by mode - group(node_cpu_seconds_total) by (mode)
- Average - avg(node_cpu_seconds_total) by (mode)
- topk{3, avg(node_cpu_seconds_total) by (mode) by (mode)}

## Time offsets
Note:
1. d = day
2. h = hour
3. m = minutes
4. ms = miliseconds
5. w = week
6. y = year

- prometheus_http_requests_total offset 10m
- Apply by code - group(prometheus_http_requests_total) by (code)
- Average - avg(prometheus_http_requests_total) by (code)
- avg(prometheus_http_requests_total ofset 8m) by (code)

## Functions in prometheus
- _absent(<Instant Vector>)_: Checks if an instant vector has any members returns an empty vector if parameter has elements
  - absent(node_cpu_seconds_total)

- _absent_over_time(<range vector>)_: Checks if an range vector has any members retruns an empty vector parameter has elements
  - absent_over_time(node_cpu_seconds_total[1h])
  - absent_over_time(node_cpu_seconds_total{cpu="xrff"}[1h])

- _abs(<Instant vector>)_: Converts all values to their absolute values. e.g -5 to 5
- _ceil(<Instant vector>)_: Converts all values to their nearest lager integer. e.g 1.6 to 2
- _floor(<Instant vector>)_: Converts all values to their nearest smaller integer. e.g 1.6 to 1
- _clamp(<Instant vector>, min, max)_
  - _clamp_min(<Instant vector>, mi)_
  - _clamp_max(<Instant vector>, max)_
    - clamp_min(node_cpu_seconds_total, 300)
    - clamp_max(node_cpu_seconds_total, 150000)
    - clamp(node_cpu_seconds_total, 300, 150000)

- _day_of_month(<instant vector>)_: For every UTC time returns day of month 1..31
- _day_of_week(<instant vector>)_: For every UTC time returns day of week 1..7
- _delta(<instant vector>)_: Can only be used with Gauges
- _idelta(<Range vector>)_: Returns the difference between first and last items
- _log2(<Instant Vector>)_: returns binary logarithm of each scaler value
- _log10(<Instant Vector>)_: returns dcimal logarithm of each scaler value
- _ln(<Instant Vector>)_: returns neutral logarithm of each scaler value
- _sort(<Instant Vector>)_: Sort elements in ascending order
- _sort_desc(<Instant Vector>)_: Sort elements in decending order
- _time(<Instant Vector>)_: Returns a near-current time stamp
- _timestamp(<Instant Vector>)_: Returns the time stamp of each time series (element)
- _avg_over_time(<range vector>)_: returns the average of items in a range vector
- _sum_over_time(<range vector>)_: returns the sum of items in a range vector
- _min_over_time(<range vector>)_: returns the minimum of items in a range vector
- _max_over_time(<range vector>)_: returns the maximum of items in a range vector
- _count_over_time(<range vector>)_: returns the count of items in a range vector

## Install Grafana
_On Ubuntu_
- Install the needed packages
  - adduser
  - libfontconfigl
  - musl
  - _sudo apt-get install -y adduser libfontconfigl musl_
- Install deb package using wget- [Download Grafana](https://grafana.com/grafana/download)
- sudo dpkg -i grafana _x_x_x_amd64.deb
- Reload the service - sudo systemctl daemon-reload
- Enable grafana server - sudo systemctl enable grafana-server
- Start grafana server - sudo systemctl start grafana-server
- Check status grafana server - sudo systemctl status grafana-server
- Lunch on browser - ip:3000

## Configure grafana
- To make any changes, go to /etc/grafana.
- It's advisable not to make changes to the grafana.ini file directly. Make a copy for example: sudo cp grafana.ini custom.ini
- Open the grafana.ini: sudo vim grafana.ini
- Remove the semi-colon in the log line to make it effective

## Dashboard Design
Dashboard dsign can be for different purposes
- _Browser Application_: To monitor browser like Angular, React applications, etc
- _APM/Backend_: To monitor application performance
- _Infrastructure (Host, Network, Disk, etc)_: To monitor infrastructure
- _Synthentic Monitors (Website up?)_: Ping the website to see it it is up
- _Business (Sales, Refunds, Payments)_: For operation purposes.

### Dashboard structure

1. Browser Applications

```
--------------------------------------------------------  ----------------------------------------------
|                                                       | |                                             |
|                                                       | |                                             |
|     HTTP ERROR RATE                                   | |     To 10 Error Messages                    |
|                                                       | |                                             |
|                                                       | |                                             |
--------------------------------------------------------- -----------------------------------------------
---------------------------------------------------------------------------------------------------------
|                                                                                                       |
|                                                                                                       |
|                           Page View load Time                                                         |
|                                                                                                       |
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
|                                                                                                       |
|                                                                                                       |
|                           Page View Per Minute                                                        |
|                                                                                                       |
---------------------------------------------------------------------------------------------------------
---------------------------------  ---------------------------------  -----------------------------------
|                               |  |                                | |                                  |
|                               |  |                                | |                                  |
| Largerst Contentful Paint(LCP)|  | First Input Dalay (FID)        | | Cumulative Layout shift (CLS)    |
|                               |  |                                | |                                  |
|                               |  |                                | |                                  |
---------------------------------  ---------------------------------- ------------------------------------
```

2. APM Service

```
--------------------------------------------------------  ----------------------------------------------
|                                                       | |                                             |
|                                                       | |                                             |
|     API Call per Minute                               | |  Error Rate Per Minute                      |
|                                                       | |                                             |
|                                                       | |                                             |
--------------------------------------------------------- -----------------------------------------------
---------------------------------------------------------------------------------------------------------
|                                                                                                       |
|                                                                                                       |
|                           Logs                                                                        |
|                                                                                                       |
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
|                                                                                                       |
|                                                                                                       |
|                           Hosts\Containers                                                            |
|                                                                                                       |
---------------------------------------------------------------------------------------------------------
--------------------------------------------------- -----------------------------------------------------
|                                                 | |                                                    |
|                                                 | |                                                    |
|       CPU Usage                                 | |                   Memory usage                     |
|                                                 | |                                                    |
|                                                 | |                                                    |
---------------------------------------------------  -----------------------------------------------------
```

3. Infrastructure

```
---------------------------------------------------------------------------------------------------------
|                                                                                                       |
|                                                                                                       |
|               Summary Info (Hosts, Applications, Events, Alerts, etc)                                 |
|                                                                                                       |
|                                                                                                       |
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
|                                                                                                       |
|                                                                                                       |
|                  Metrics (CPU, Memory, Disk Used, Disk Utilisation)                                   |
|                                                                                                       |
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
|                                                                                                       |
|                                                                                                       |
|                           Hosts\Containers                                                            |
|                                                                                                       |
---------------------------------------------------------------------------------------------------------
--------------------------------------------------- -----------------------------------------------------
|                                                 | |                                                    |
|                                                 | |                                                    |
|       Databases                                 | |    Distribute Cache (and similar)                  |
|                                                 | |                                                    |
|                                                 | |                                                    |
---------------------------------------------------  -----------------------------------------------------
```

4. Synthetic Monitors

```
--------------------------------------------------------  ----------------------------------------------
|                                                       | |                                             |
|                                                       | |                                             |
|     Loading page up view/alert                        | |  APIs Health check Status                   |
|                                                       | |                                             |
|                                                       | |                                             |
--------------------------------------------------------- -----------------------------------------------
---------------------------------------------------------------------------------------------------------
|                                                                                                       |
|                                                                                                       |
|                    Page load performance                                                              |
|                                                                                                       |
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
|                                                                                                       |
|                                                                                                       |
|                    External system status                                                             |
|                                                                                                       |
---------------------------------------------------------------------------------------------------------
```

5. Business information

```
--------------------------------------------------------  ----------------------------------------------
|                                                       | |                                             |
|                                                       | |                                             |
| Total sales count, refundcount, Sales value, refund   | | Sales by region/country                     |
|    value (This month to previous month)               | |  (This month to previous month)             |
|                                                       | |                                             |
--------------------------------------------------------- -----------------------------------------------
---------------------------------  ---------------------------------  -----------------------------------
|                               |  |                                | |                                  |
|                               |  |                                | |                                  |
| Conversion Rate               |  | Customer Acquisition           | | Abandoned checkout               |
|                               |  |   (New customers)              | |                                  |
|                               |  |                                | |                                  |
---------------------------------  ---------------------------------- ------------------------------------
---------------------------------  ---------------------------------  -----------------------------------
|                               |  |                                | |                                  |
|                               |  |                                | |                                  |
| Top payment methods           |  | Payment VS refund (count)      | |  Basket value                    |
|                               |  |                                | |                                  |
|                               |  |                                | |                                  |
---------------------------------  ---------------------------------- ------------------------------------
```

## Connecting Grafana to prometheus
- Login to grafana 
- In the homepage, click the configuration (Like setting icon)
- Click on the Datasource option
- Click on Add button
- Select prometheus
- HTTP
  - URL - Add the promethus URL
- Auth
  - if you enable authentication in prometheus, you trun ot on here and provide the authentication details