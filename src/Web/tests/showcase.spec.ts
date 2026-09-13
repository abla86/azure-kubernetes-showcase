import { expect, test } from "@playwright/test";

test.describe("Azure Kubernetes Showcase web app", () => {
  test("loads the application shell", async ({ page }) => {
    await page.goto("/");
    await expect(page).toHaveTitle(/Azure Kubernetes Showcase/i);
    await expect(page.getByRole("heading", { name: "Azure Kubernetes Showcase" })).toBeVisible();
    await expect(page.getByText("Engineering pipeline")).toBeVisible();
  });

  test("renders API-backed health and info", async ({ page }) => {
    await page.route("/api/health", async route => route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify({ status: "healthy", service: "azure-kubernetes-showcase", timestamp: new Date().toISOString() }) }));
    await page.route("/api/info", async route => route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify({ application: "Azure Kubernetes Showcase", version: "1.0.0", runtime: ".NET 10", environment: "Test" }) }));
    await page.route("/api/events", async route => route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify([]) }));
    await page.goto("/");
    await expect(page.getByText("SERVICE HEALTH")).toBeVisible();
    await expect(page.getByText("healthy", { exact: true })).toBeVisible();
    await expect(page.getByText(".NET 10", { exact: true })).toBeVisible();
  });

  test("renders system events", async ({ page }) => {
    await page.route("/api/health", async route => route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify({ status: "healthy", service: "azure-kubernetes-showcase", timestamp: new Date().toISOString() }) }));
    await page.route("/api/info", async route => route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify({ application: "Azure Kubernetes Showcase", version: "1.0.0", runtime: ".NET 10", environment: "Test" }) }));
    await page.route("/api/events", async route => route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify([{ type: "deployment", message: "Application running", timestamp: new Date().toISOString() }, { type: "observability", message: "Health and telemetry endpoints enabled", timestamp: new Date().toISOString() }]) }));
    await page.goto("/");
    await expect(page.getByRole("heading", { name: "System events" })).toBeVisible();
    await expect(page.getByText("Application running", { exact: true })).toBeVisible();
    await expect(page.getByText("Health and telemetry endpoints enabled", { exact: true })).toBeVisible();
  });
});
