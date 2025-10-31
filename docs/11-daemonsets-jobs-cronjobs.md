# Module 11: DaemonSets, Jobs & CronJobs

## Overview

This module covers specialized workload types: DaemonSets for node-level services, Jobs for one-time tasks, and CronJobs for scheduled tasks.

## Learning Objectives

- Create and manage DaemonSets
- Run batch jobs with Jobs
- Schedule recurring tasks with CronJobs
- Understand use cases for each workload type

## DaemonSets

### What is a DaemonSet?

A **DaemonSet** ensures that a copy of a pod runs on all (or some) nodes in the cluster.

### Use Cases

- Log collection agents (Fluentd, Filebeat)
- Monitoring agents (Prometheus Node Exporter)
- Network plugins (Calico, Weave)
- Storage daemons (Ceph, GlusterFS)

### DaemonSet Example

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-daemonset
  namespace: kube-system
  labels:
    app: fluentd
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluent/fluentd:v1.14
        resources:
          limits:
            memory: 200Mi
            cpu: 100m
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```

### DaemonSet Commands

```bash
# Create DaemonSet
kubectl apply -f daemonset.yaml

# List DaemonSets
kubectl get daemonsets
kubectl get ds

# Describe DaemonSet
kubectl describe daemonset fluentd-daemonset

# Update DaemonSet
kubectl set image daemonset/fluentd-daemonset fluentd=fluent/fluentd:v1.15

# Delete DaemonSet
kubectl delete daemonset fluentd-daemonset
```

## Jobs

### What is a Job?

A **Job** creates one or more pods and ensures they successfully complete.

### Use Cases

- Data processing
- Database migrations
- Batch processing
- Report generation
- Backups

### Job Example

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processing-job
spec:
  # Number of successful completions needed
  completions: 5
  
  # Number of pods to run in parallel
  parallelism: 2
  
  # Retry limit
  backoffLimit: 4
  
  # Timeout
  activeDeadlineSeconds: 600
  
  template:
    spec:
      restartPolicy: OnFailure  # or Never
      containers:
      - name: processor
        image: busybox
        command: ["sh", "-c", "echo Processing data... && sleep 30 && echo Done"]
```

### Job Parameters

- **completions**: How many pods must succeed
- **parallelism**: How many pods run simultaneously
- **backoffLimit**: Max retries on failure
- **activeDeadlineSeconds**: Max runtime
- **restartPolicy**: OnFailure or Never

### Job Commands

```bash
# Create Job
kubectl create job my-job --image=busybox -- echo "Hello World"

# Or from YAML
kubectl apply -f job.yaml

# List Jobs
kubectl get jobs

# View Job details
kubectl describe job data-processing-job

# View Job logs
kubectl logs job/data-processing-job

# Delete Job (and its pods)
kubectl delete job data-processing-job

# Delete Job but keep pods
kubectl delete job data-processing-job --cascade=orphan
```

## CronJobs

### What is a CronJob?

A **CronJob** creates Jobs on a schedule (like cron in Linux).

### Use Cases

- Scheduled backups
- Report generation
- Data cleanup
- Health checks
- Batch processing

### CronJob Example

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-cronjob
spec:
  # Cron schedule (minute hour day month weekday)
  schedule: "0 2 * * *"  # Every day at 2 AM
  
  # Timezone (Kubernetes 1.25+)
  timeZone: "America/New_York"
  
  # Job history limits
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  
  # Concurrency policy
  concurrencyPolicy: Forbid  # Allow, Forbid, or Replace
  
  # Suspend executions
  suspend: false
  
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: backup
            image: busybox
            command: ["sh", "-c", "echo Performing backup at $(date)"]
```

### Cron Schedule Format

```
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of week (0 - 6) (Sunday=0)
# │ │ │ │ │
# * * * * *

Examples:
"0 * * * *"      # Every hour
"*/5 * * * *"    # Every 5 minutes
"0 0 * * *"      # Every day at midnight
"0 2 * * *"      # Every day at 2 AM
"0 0 * * 0"      # Every Sunday at midnight
"0 0 1 * *"      # First day of every month
"0 0 1 1 *"      # January 1st every year
```

### Concurrency Policies

- **Allow**: Allow concurrent jobs (default)
- **Forbid**: Skip new job if previous still running
- **Replace**: Cancel old job and start new one

### CronJob Commands

```bash
# Create CronJob
kubectl create cronjob my-cronjob --image=busybox --schedule="*/5 * * * *" -- echo "Hello"

# Or from YAML
kubectl apply -f cronjob.yaml

# List CronJobs
kubectl get cronjobs
kubectl get cj

# View CronJob details
kubectl describe cronjob backup-cronjob

# Manually trigger CronJob
kubectl create job manual-job --from=cronjob/backup-cronjob

# Suspend CronJob
kubectl patch cronjob backup-cronjob -p '{"spec":{"suspend":true}}'

# Resume CronJob
kubectl patch cronjob backup-cronjob -p '{"spec":{"suspend":false}}'

# Delete CronJob
kubectl delete cronjob backup-cronjob
```

## Hands-On Labs

### Lab 1: DaemonSet

```bash
# Create DaemonSet
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-logger
spec:
  selector:
    matchLabels:
      app: node-logger
  template:
    metadata:
      labels:
        app: node-logger
    spec:
      containers:
      - name: logger
        image: busybox
        command: ["sh", "-c", "while true; do echo Logging from \$(hostname); sleep 60; done"]
EOF

# View DaemonSet
kubectl get daemonsets
kubectl get pods -l app=node-logger -o wide

# Check logs from multiple nodes
kubectl logs -l app=node-logger --tail=5
```

### Lab 2: Batch Job

```bash
# Create Job
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-calculator
spec:
  completions: 5
  parallelism: 2
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: pi
        image: perl:5.34
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
EOF

# Watch Job progress
kubectl get jobs -w

# View pods
kubectl get pods -l job-name=pi-calculator

# View logs
kubectl logs job/pi-calculator
```

### Lab 3: CronJob

```bash
# Create CronJob (runs every minute)
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello-cronjob
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: Never
          containers:
          - name: hello
            image: busybox
            command: ["sh", "-c", "echo Hello from CronJob at \$(date)"]
EOF

# Watch CronJob create Jobs
kubectl get cronjobs -w

# View created Jobs
kubectl get jobs

# View logs
kubectl logs -l app=hello-cronjob --tail=10

# Manually trigger
kubectl create job manual-hello --from=cronjob/hello-cronjob

# Suspend CronJob
kubectl patch cronjob hello-cronjob -p '{"spec":{"suspend":true}}'
```

## Key Takeaways

1. **DaemonSets** - One pod per node (monitoring, logging, storage)
2. **Jobs** - Run to completion (batch processing, migrations)
3. **CronJobs** - Scheduled Jobs (backups, reports, cleanup)
4. **Use appropriate workload type** - Choose based on use case
5. **Set resource limits** - Especially for DaemonSets
6. **Configure retries** - backoffLimit for Jobs
7. **Manage history** - successfulJobsHistoryLimit for CronJobs

## Next Steps

- **[Module 12: ConfigMaps & Secrets](12-configmaps-secrets.md)**
- Practice with examples in `examples/daemonsets/`, `examples/jobs/`, `examples/cronjobs/`

## Additional Resources

- [Kubernetes DaemonSets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
- [Kubernetes Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [Kubernetes CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)
