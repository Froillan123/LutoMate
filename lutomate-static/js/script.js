// Mobile menu toggle functionality
let menuIcon = document.querySelector('#menu-icon');
let navbar = document.querySelector('.navbar');

menuIcon.onclick = () => {
    menuIcon.classList.toggle('bx-x');
    navbar.classList.toggle('active');
};

// Close mobile menu when clicking outside
document.addEventListener('click', (e) => {
    if (!menuIcon.contains(e.target) && !navbar.contains(e.target)) {
        menuIcon.classList.remove('bx-x');
        navbar.classList.remove('active');
    }
});

// Dropdown menu functionality
let dropdowns = document.querySelectorAll('.dropdown > a');

dropdowns.forEach(dropdown => {
    dropdown.addEventListener('click', (e) => {
        if (window.innerWidth <= 768) {
            e.preventDefault();
            let dropdownMenu = dropdown.parentElement.querySelector('.dropdown-menu');
            let isActive = dropdown.parentElement.classList.contains('active');
            
            // Close all other dropdowns first
            document.querySelectorAll('.dropdown').forEach(item => {
                if (item !== dropdown.parentElement) {
                    item.classList.remove('active');
                    item.querySelector('.dropdown-menu').style.display = 'none';
                }
            });
            
            // Toggle current dropdown
            dropdown.parentElement.classList.toggle('active');
            dropdownMenu.style.display = isActive ? 'none' : 'block';
        }
    });
});

// Close mobile menu when clicking on a regular link (not dropdown toggle)
document.querySelectorAll('.navbar a:not(.dropdown > a)').forEach(link => {
    link.addEventListener('click', () => {
        if (window.innerWidth <= 768) {
            navbar.classList.remove('active');
            menuIcon.classList.remove('bx-x');
        }
    });
});

// Sticky header and section highlighting
let sections = document.querySelectorAll('section');
let navLinks = document.querySelectorAll('header nav a:not(.dropdown-menu a)');

window.onscroll = () => {
    // Section highlighting
    sections.forEach(sec => {
        let top = window.scrollY;
        let offset = sec.offsetTop - 120;
        let height = sec.offsetHeight;
        let id = sec.getAttribute('id');

        if (top >= offset && top < offset + height) {
            navLinks.forEach(link => {
                link.classList.remove('active');
                let href = link.getAttribute('href');
                if (href && href.includes(id)) {
                    link.classList.add('active');
                }
            });
        }
    });

    // Sticky header
    let header = document.querySelector('header');
    header.classList.toggle('sticky', window.scrollY > 100);
};

// Smooth scrolling for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        // Don't prevent default for dropdown toggles on mobile
        if (this.classList.contains('dropdown-toggle') && window.innerWidth <= 768) {
            return;
        }
        
        e.preventDefault();
        
        const targetId = this.getAttribute('href');
        if (targetId === '#') return;
        
        const targetElement = document.querySelector(targetId);
        if (targetElement) {
                    window.scrollTo({
            top: targetElement.offsetTop - 100,
            behavior: 'smooth'
        });
            
            // Close mobile menu after clicking
            if (window.innerWidth <= 768) {
                navbar.classList.remove('active');
                menuIcon.classList.remove('bx-x');
            }
        }
    });
});

// Animation on scroll for feature cards and steps
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
    // Set current year in copyright
    const currentYearElement = document.getElementById('current-year');
    if (currentYearElement) {
        currentYearElement.textContent = new Date().getFullYear();
    }
    
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

// Handle window resize events
window.addEventListener('resize', () => {
    // Close mobile menu when resizing to desktop
    if (window.innerWidth > 768) {
        navbar.classList.remove('active');
        menuIcon.classList.remove('bx-x');
        
        // Reset dropdown menus
        document.querySelectorAll('.dropdown-menu').forEach(menu => {
            menu.style.display = '';
        });
    }
});