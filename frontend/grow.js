const bindUpgrade = () => {
  const button = document.getElementById("upgrade-button");
  const message = document.getElementById("upgrade-message");
  if (!button) return;

  button.addEventListener("click", async () => {
    if (!requireAuth()) return;

    button.disabled = true;
    button.textContent = "Upgrading...";

    try {
      const data = await request("/api/accounts/upgrade/", {
        method: "POST",
      });
      await refreshCurrentUser();
      initNav();
      setMessage(message, `Upgrade complete. New role: ${data.role}.`);
    } catch (error) {
      showError(button.parentElement, error.message);
      setMessage(message, error.message);
    } finally {
      button.disabled = false;
      button.textContent = "Upgrade to Grower";
    }
  });
};

document.addEventListener("DOMContentLoaded", bindUpgrade);
