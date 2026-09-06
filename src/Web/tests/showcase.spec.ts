import { expect, test } from "@playwright/test";

test.describe("Azure Kubernetes Showcase web app", () => {
  test("loads the application shell", async ({ page }) => {
    await page.goto("/");
    await expect(page).toHaveTitle(/Azure Kubernetes Showcase/i);
    await expect(page.getByRole("heading", { name: "Azure Kubernetes Showcase" })).toBeVisible();
    await expect(page.getByText("Engineering pipeline")).toBeVisible();
  });

  test("renders API-backed health and info", async ({ page }) => {
    await page.goto("/");
    await expect(page.getByText("SERVICE HEALTH")).toBeVisible();
    await expect(page.getByText("healthy", { exact: true })).toBeVisible();
    await expect(page.getByText(".NET 10", { exact: true })).toBeVisible();
  });

  test("renders system events", async ({ page }) => {
    await page.goto("/");
    await expect(page.getByRole("heading", { name: "System events" })).toBeVisible();
    await expect(page.getByText("Application running", { exact: true })).toBeVisible();
    await expect(page.getByText("Health and telemetry endpoints enabled", { exact: true })).toBeVisible();
  });
});
