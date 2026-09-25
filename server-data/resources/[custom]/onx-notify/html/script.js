window.addEventListener('message', function(event) {
    let data = event.data;
    if (data.action === "notify") {
        createNotification(data.text, data.type, data.length);
    }
});

function createNotification(text, type, length) {
    let icon = "fa-solid fa-circle-info";
    if (type === "success") icon = "fa-solid fa-check-circle";
    else if (type === "error") icon = "fa-solid fa-circle-xmark";
    else if (type === "warning") icon = "fa-solid fa-triangle-exclamation";

    let $notification = $(`
        <div class="notification ${type}">
            <i class="notification-icon ${icon}"></i>
            <span class="notification-text">${text}</span>
        </div>
    `);

    $("#notifications-container").append($notification);

    setTimeout(() => {
        $notification.addClass('show');
    }, 10);

    setTimeout(() => {
        $notification.removeClass('show').addClass('hide');
        setTimeout(() => {
            $notification.remove();
        }, 300);
    }, length);
}
