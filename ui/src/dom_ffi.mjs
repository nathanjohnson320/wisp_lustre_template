export function rect_xy(id) {
    const element = document.getElementById(id);
    const rect = element.getBoundingClientRect();
    return [rect.left, rect.top];
}

export function document_mouse_move(cb) {
    document.addEventListener('mousemove', function (e) {
        cb(e.clientX, e.clientY);
    });
}

export function document_mouse_up(cb) {
    document.addEventListener('mouseup', function (e) {
        cb();
    });
}