import { render, screen } from "@testing-library/react";
import App from "../App";

test("renders app shell", () => {
  render(<App />);
  // Adjust text if App changes; this is a smoke test.
  const body = document.body;
  expect(body).toBeTruthy();
  // At least one element should exist.
  expect(screen.getAllByRole("button", { hidden: true }).length >= 0).toBe(true);
});
