// Smooth scrolling for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        
        const targetId = this.getAttribute('href');
        if (targetId === '#') return;
        
        const targetElement = document.querySelector(targetId);
        if (targetElement) {
            window.scrollTo({
                top: targetElement.offsetTop - 80,
                behavior: 'smooth'
            });
        }
    });
});

// Mobile menu toggle (would be added for smaller screens)
function setupMobileMenu() {
    const menuToggle = document.createElement('button');
    menuToggle.className = 'menu-toggle';
    menuToggle.innerHTML = '☰';
    menuToggle.setAttribute('aria-label', 'Toggle menu');
    
    const header = document.querySelector('header .container');
    const nav = document.querySelector('nav');
    
    if (window.innerWidth < 768) {
        header.insertBefore(menuToggle, nav);
        nav.style.display = 'none';
        
        menuToggle.addEventListener('click', () => {
            if (nav.style.display === 'none' || !nav.style.display) {
                nav.style.display = 'block';
                menuToggle.innerHTML = '✕';
            } else {
                nav.style.display = 'none';
                menuToggle.innerHTML = '☰';
            }
        });
        
        // Close menu when clicking on a link
        document.querySelectorAll('nav a').forEach(link => {
            link.addEventListener('click', () => {
                nav.style.display = 'none';
                menuToggle.innerHTML = '☰';
            });
        });
    } else {
        const existingToggle = document.querySelector('.menu-toggle');
        if (existingToggle) {
            existingToggle.remove();
        }
        nav.style.display = 'block';
    }
}

// Initialize mobile menu and set up resize listener
window.addEventListener('DOMContentLoaded', setupMobileMenu);
window.addEventListener('resize', setupMobileMenu);

// Animation on scroll
function animateOnScroll() {
    const elements = document.querySelectorAll('.feature-card, .step');
    
    elements.forEach(element => {
        const elementPosition = element.getBoundingClientRect().top;
        const screenPosition = window.innerHeight / 1.2;
        
        if (elementPosition < screenPosition) {
            element.style.opacity = '1';
            element.style.transform = 'translateY(0)';
        }
    });
}

// Set initial styles for animation
document.addEventListener('DOMContentLoaded', () => {
    const features = document.querySelectorAll('.feature-card');
    const steps = document.querySelectorAll('.step');
    
    features.forEach((card, index) => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = `opacity 0.5s ease ${index * 0.1}s, transform 0.5s ease ${index * 0.1}s`;
    });
    
    steps.forEach((step, index) => {
        step.style.opacity = '0';
        step.style.transform = 'translateY(20px)';
        step.style.transition = `opacity 0.5s ease ${index * 0.2}s, transform 0.5s ease ${index * 0.2}s`;
    });
    
    // Trigger initial check
    animateOnScroll();
});

window.addEventListener('scroll', animateOnScroll);

// APK download tracking (example)
document.querySelectorAll('a[href$=".apk"]').forEach(link => {
    link.addEventListener('click', () => {
        // In a real app, you might send analytics here
        console.log('APK download initiated');
    });
});