const initCommunity = async () => {
  const feed = document.getElementById("posts-feed");
  const section = document.getElementById("new-post-section");
  const form = document.getElementById("post-form");
  const message = document.getElementById("post-message");

  // Show new-post form for logged-in users
  if (getToken() && section) section.style.display = "";

  // Load posts
  if (feed) {
    showLoading(feed);
    try {
      const [posts, photos] = await Promise.all([
        request("/api/posts/"),
        request("/api/photos/").catch(() => []),
      ]);

      const photosByPost = {};
      for (const p of photos) {
        (photosByPost[p.post] ||= []).push(p);
      }

      if (posts.length === 0) {
        feed.innerHTML = "<p>No posts yet.</p>";
      } else {
        feed.innerHTML = posts
          .map((post) => {
            const postPhotos = (photosByPost[post.id] || [])
              .map((ph) => `<img class="post-photo" src="${ph.image}" alt="Post photo" />`)
              .join("");
            return `
              <article class="panel post-card">
                <p class="post-meta">Post #${post.id} &middot; ${new Date(post.created_at).toLocaleDateString()}</p>
                <p>${post.text}</p>
                ${postPhotos ? `<div class="post-photos">${postPhotos}</div>` : ""}
              </article>
            `;
          })
          .join("");
      }
    } catch (error) {
      feed.innerHTML = "";
      showError(feed, `Could not load posts: ${error.message}`);
    }
  }

  // Handle new post creation
  if (form) {
    form.addEventListener("submit", async (event) => {
      event.preventDefault();
      const submitBtn = form.querySelector('[type="submit"]');
      submitBtn.disabled = true;
      submitBtn.textContent = "Publishing...";
      dismissError(form.parentElement);

      const data = new FormData(form);
      const plantValue = data.get("plant");
      const text = data.get("text");
      const imageFile = data.get("image");

      if (!text || !text.trim()) {
        showError(form.parentElement, "Post text is required.");
        submitBtn.disabled = false;
        submitBtn.textContent = "Post";
        return;
      }

      try {
        const post = await request("/api/posts/", {
          method: "POST",
          body: JSON.stringify({ plant: plantValue, text }),
        });

        // Upload photo if provided
        if (imageFile && imageFile.size > 0) {
          const photoData = new FormData();
          photoData.append("post", post.id);
          photoData.append("image", imageFile);
          await request("/api/photos/", {
            method: "POST",
            body: photoData,
            multipart: true,
          });
        }

        setMessage(message, "Post published!");
        form.reset();
        // Reload feed
        initCommunity();
      } catch (error) {
        showError(form.parentElement, error.message);
        setMessage(message, error.message);
      } finally {
        submitBtn.disabled = false;
        submitBtn.textContent = "Post";
      }
    });
  }
};

document.addEventListener("DOMContentLoaded", initCommunity);
