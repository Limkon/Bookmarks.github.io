const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');

let snake;
let direction;
let food;
let score;

function resetGame() {
    snake = [{ x: 10, y: 10 }];
    direction = { x: 0, y: 0 };
    food = { x: 15, y: 15 };
    score = 0;
}

function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    // Draw snake
    snake.forEach((segment, index) => {
        ctx.fillStyle = index === 0 ? 'green' : 'lightgreen';
        ctx.beginPath();
        ctx.arc(segment.x * 20 + 10, segment.y * 20 + 10, 9, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();
    });

    // Draw food
    ctx.fillStyle = 'red';
    ctx.beginPath();
    ctx.arc(food.x * 20 + 10, food.y * 20 + 10, 9, 0, Math.PI * 2);
    ctx.fill();

    // Move snake
    const head = { x: snake[0].x + direction.x, y: snake[0].y + direction.y };
    
    if (head.x === food.x && head.y === food.y) {
        score++;
        food = { x: Math.floor(Math.random() * (canvas.width / 20)), y: Math.floor(Math.random() * (canvas.height / 20)) };
    } else {
        snake.pop();
    }

    snake.unshift(head);

    // Check for collisions
    if (head.x < 0 || head.x >= canvas.width / 20 || head.y < 0 || head.y >= canvas.height / 20 || collision(head)) {
        alert('游戏结束！得分：' + score);
        resetGame(); // Reset the game state
    }
}

function collision(head) {
    return snake.slice(1).some(segment => segment.x === head.x && segment.y === head.y);
}

function changeDirection(event) {
    switch (event.key) {
        case 'ArrowUp':
            if (direction.y === 0) direction = { x: 0, y: -1 };
            break;
        case 'ArrowDown':
            if (direction.y === 0) direction = { x: 0, y: 1 };
            break;
        case 'ArrowLeft':
            if (direction.x === 0) direction = { x: -1, y: 0 };
            break;
        case 'ArrowRight':
            if (direction.x === 0) direction = { x: 1, y: 0 };
            break;
    }
}

document.addEventListener('keydown', changeDirection);
resetGame(); // Initialize the game state
setInterval(draw, 100);