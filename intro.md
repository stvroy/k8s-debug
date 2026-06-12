# Debug a Broken Kubernetes Deployment

## Scenario

You are the on-call DevOps engineer at **Living Goods**, a non-profit running community health worker programs.

A developer deployed a new version of the `api-gateway` service to the `production` namespace **10 minutes ago**. Since then, users have been unable to reach the application.

The developer says: *"I just applied the manifest, everything looks fine to me."*

It is your job to prove otherwise.

---

## Your Task

Investigate the `production` namespace, find **every bug** in the deployment, and fix them so that:

- All pods are in **Running** and **Ready** state
- The Service has **healthy endpoints**
- The application is **reachable** within the cluster

---

## Rules

- Do not delete and recreate the deployment — **patch or edit** what is broken
- Explain each bug out loud as you find it before you fix it
- You have **10 minutes**

---


Good luck!
