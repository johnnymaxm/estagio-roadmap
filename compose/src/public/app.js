document.addEventListener('DOMContentLoaded', () => {
    const itemForm = document.getElementById('itemForm');
    const itemsList = document.getElementById('itemsList');

    // Load items when page loads
    loadItems();

    // Handle form submission
    itemForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const formData = {
            name: document.getElementById('name').value,
            description: document.getElementById('description').value
        };

        try {
            const response = await fetch('/api/items', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(formData)
            });

            if (!response.ok) {
                throw new Error('Failed to add item');
            }

            // Clear form
            itemForm.reset();

            // Reload items
            loadItems();

            // Show success message
            alert('Item added successfully!');
        } catch (error) {
            console.error('Error:', error);
            alert('Failed to add item. Please try again.');
        }
    });

    // Function to load and display items
    async function loadItems() {
        try {
            const response = await fetch('/api/items');
            if (!response.ok) {
                throw new Error('Failed to fetch items');
            }

            const items = await response.json();
            displayItems(items);
        } catch (error) {
            console.error('Error:', error);
            itemsList.innerHTML = '<p class="error">Failed to load items. Please refresh the page.</p>';
        }
    }

    // Function to display items
    function displayItems(items) {
        if (items.length === 0) {
            itemsList.innerHTML = '<p>No items yet. Add your first item!</p>';
            return;
        }

        itemsList.innerHTML = items.map(item => `
            <div class="item-card">
                <h3>${escapeHtml(item.name)}</h3>
                <p>${escapeHtml(item.description)}</p>
                <div class="date">Created: ${new Date(item.createdAt).toLocaleString()}</div>
            </div>
        `).join('');
    }

    // Helper function to prevent XSS
    function escapeHtml(unsafe) {
        return unsafe
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }
}); 