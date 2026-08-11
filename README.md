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
 
