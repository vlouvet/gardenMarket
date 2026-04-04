const bindUpgrade = () => {
  const button = document.getElementById("upgrade-button");
  const message = document.getElementById("upgrade-message");
  if (!button) return;

  button.addEventListener("click", async () => {
    if (!requireAuth()) return;

    try {
      const data = await request("/api/accounts/upgrade/", {
        method: "POST",
      });
      setMessage(message, `Upgrade complete. New role: ${data.role}.`);
    } catch (error) {
      setMessage(message, error.message);
    }
  });
};

document.addEventListener("DOMContentLoaded", bindUpgrade);
