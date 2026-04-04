const loadProfile = async () => {
  if (!requireAuth()) return;

  const form = document.getElementById("profile-form");
  const emailEl = document.getElementById("account-email");
  const roleEl = document.getElementById("account-role");
  const message = document.getElementById("profile-message");
  if (!form) return;

  const submitBtn = form.querySelector('[type="submit"]');

  try {
    const [profile, me] = await Promise.all([
      request("/api/accounts/profile/"),
      request("/api/accounts/me/"),
    ]);

    form.address_line1.value = profile.address_line1 || "";
    form.address_line2.value = profile.address_line2 || "";
    form.city.value = profile.city || "";
    form.state.value = profile.state || "";
    form.postal_code.value = profile.postal_code || "";
    form.country.value = profile.country || "";

    if (emailEl) emailEl.textContent = me.email || "--";
    if (roleEl) roleEl.textContent = me.role || "--";
  } catch (error) {
    showError(form.parentElement, `Could not load profile: ${error.message}`);
  }

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    submitBtn.disabled = true;
    submitBtn.textContent = "Saving...";
    dismissError(form.parentElement);

    const payload = Object.fromEntries(new FormData(form).entries());
    try {
      await request("/api/accounts/profile/", {
        method: "PATCH",
        body: JSON.stringify(payload),
      });
      setMessage(message, "Profile updated.");
    } catch (error) {
      showError(form.parentElement, error.message);
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = "Save profile";
    }
  });

  // Logout button (page-specific, in addition to nav)
  const logoutBtn = document.getElementById("logout-button");
  if (logoutBtn) {
    logoutBtn.addEventListener("click", logout);
  }
};

document.addEventListener("DOMContentLoaded", loadProfile);
