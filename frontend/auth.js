const bindRegister = () => {
  const form = document.getElementById("register-form");
  const message = document.getElementById("register-message");
  if (!form) return;

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
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
      setMessage(message, "Account created. Access token stored.");
      initNav();
    } catch (error) {
      setMessage(message, error.message);
    }
  });
};

const bindLogin = () => {
  const form = document.getElementById("login-form");
  const message = document.getElementById("login-message");
  if (!form) return;

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    const formData = new FormData(form);
    const payload = Object.fromEntries(formData.entries());

    try {
      const login = await request("/api/accounts/login/", {
        method: "POST",
        body: JSON.stringify(payload),
      });
      storeToken(login.access);
      setMessage(message, "Signed in. Access token stored.");
      initNav();
    } catch (error) {
      setMessage(message, error.message);
    }
  });
};

document.addEventListener("DOMContentLoaded", () => {
  bindRegister();
  bindLogin();
});
