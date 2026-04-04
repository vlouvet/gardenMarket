/* ── password strength ────────────────────────────────────────── */

const getPasswordStrength = (pw) => {
  let score = 0;
  if (pw.length >= 8) score++;
  if (pw.length >= 12) score++;
  if (/[A-Z]/.test(pw)) score++;
  if (/[0-9]/.test(pw)) score++;
  if (/[^A-Za-z0-9]/.test(pw)) score++;
  return Math.min(score, 5);
};

const renderStrengthBar = (container, score) => {
  if (!container) return;
  const labels = ["", "Weak", "Fair", "Good", "Strong", "Very strong"];
  container.innerHTML =
    '<div class="password-strength">' +
    Array.from({ length: 5 }, (_, i) => {
      const filled = i < score;
      const strong = score >= 4 && filled;
      return `<div class="password-strength-bar${filled ? " filled" : ""}${strong ? " strong" : ""}"></div>`;
    }).join("") +
    "</div>" +
    `<span class="password-hint">${labels[score] || ""}</span>`;
};

/* ── inline field validation ─────────────────────────────────── */

const showFieldError = (input, message) => {
  clearFieldError(input);
  input.classList.add("invalid");
  input.classList.remove("valid");
  const err = document.createElement("span");
  err.className = "field-error";
  err.textContent = message;
  input.parentElement.appendChild(err);
};

const clearFieldError = (input) => {
  input.classList.remove("invalid");
  const existing = input.parentElement.querySelector(".field-error");
  if (existing) existing.remove();
};

const markValid = (input) => {
  clearFieldError(input);
  input.classList.add("valid");
};

const validateEmail = (input) => {
  const v = input.value.trim();
  if (!v) { showFieldError(input, "Email is required"); return false; }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v)) { showFieldError(input, "Enter a valid email address"); return false; }
  markValid(input);
  return true;
};

const validatePassword = (input, minLength = 8) => {
  const v = input.value;
  if (!v) { showFieldError(input, "Password is required"); return false; }
  if (v.length < minLength) { showFieldError(input, `Must be at least ${minLength} characters`); return false; }
  markValid(input);
  return true;
};

/* ── register form ───────────────────────────────────────────── */

const bindRegister = () => {
  const form = document.getElementById("register-form");
  const message = document.getElementById("register-message");
  if (!form) return;

  const emailInput = form.querySelector('[name="email"]');
  const passwordInput = form.querySelector('[name="password"]');

  // Live validation
  emailInput.addEventListener("blur", () => validateEmail(emailInput));

  // Password strength meter — insert container after the password input
  const strengthContainer = document.createElement("div");
  passwordInput.parentElement.appendChild(strengthContainer);

  passwordInput.addEventListener("input", () => {
    renderStrengthBar(strengthContainer, getPasswordStrength(passwordInput.value));
  });
  passwordInput.addEventListener("blur", () => validatePassword(passwordInput));

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    // Validate all fields before submit
    const emailOk = validateEmail(emailInput);
    const pwOk = validatePassword(passwordInput);
    if (!emailOk || !pwOk) return;

    const submitBtn = form.querySelector('[type="submit"]');
    submitBtn.disabled = true;
    submitBtn.textContent = "Creating account...";

    const formData = new FormData(form);
    const payload = Object.fromEntries(formData.entries());

    try {
      await request("/api/accounts/register/", {
        method: "POST",
        body: JSON.stringify(payload),
      });
      const login = await request("/api/accounts/login/", {
        method: "POST",
        body: JSON.stringify({
          email: payload.email,
          password: payload.password,
        }),
      });
      storeToken(login.access);
      await refreshCurrentUser();
      initNav();
      setMessage(message, "Account created! Redirecting...", "success");
      setTimeout(() => (window.location.href = "index.html"), 800);
    } catch (error) {
      showError(form.parentElement, error.message);
      setMessage(message, error.message);
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = "Create account";
    }
  });
};

/* ── login form ──────────────────────────────────────────────── */

const bindLogin = () => {
  const form = document.getElementById("login-form");
  const message = document.getElementById("login-message");
  if (!form) return;

  const emailInput = form.querySelector('[name="email"]');
  const passwordInput = form.querySelector('[name="password"]');

  emailInput.addEventListener("blur", () => validateEmail(emailInput));
  passwordInput.addEventListener("blur", () => {
    if (!passwordInput.value) showFieldError(passwordInput, "Password is required");
    else clearFieldError(passwordInput);
  });

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    const emailOk = validateEmail(emailInput);
    const pwOk = !!passwordInput.value;
    if (!pwOk) showFieldError(passwordInput, "Password is required");
    if (!emailOk || !pwOk) return;

    const submitBtn = form.querySelector('[type="submit"]');
    submitBtn.disabled = true;
    submitBtn.textContent = "Signing in...";

    const formData = new FormData(form);
    const payload = Object.fromEntries(formData.entries());

    try {
      const login = await request("/api/accounts/login/", {
        method: "POST",
        body: JSON.stringify(payload),
      });
      storeToken(login.access);
      await refreshCurrentUser();
      initNav();
      setMessage(message, "Signed in! Redirecting...", "success");
      setTimeout(() => (window.location.href = "index.html"), 800);
    } catch (error) {
      showError(form.parentElement, error.message);
      setMessage(message, error.message);
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = "Sign in";
    }
  });
};

document.addEventListener("DOMContentLoaded", () => {
  bindRegister();
  bindLogin();
});
