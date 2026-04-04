const initCommunity = async () => {
  const feed = document.getElementById("posts-feed");
  const section = document.getElementById("new-post-section");
  const form = document.getElementById("post-form");
  const message = document.getElementById("post-message");

  // Show new-post form for logged-in users
  if (getToken() && section) section.style.display = "";

  // Load posts
  if (feed) {
    feed.innerHTML = "<p>Loading posts...</p>";
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
    } catch {
      feed.innerHTML = "<p>Could not load posts.</p>";
    }
  }

  // Handle new post creation
  if (form) {
    form.addEventListener("submit", async (event) => {
      event.preventDefault();
      const data = new FormData(form);
      const plantValue = data.get("plant");
      const text = data.get("text");
      const imageFile = data.get("image");

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
        setMessage(message, error.message);
      }
    });
  }
};

document.addEventListener("DOMContentLoaded", initCommunity);
