export function redirectToLogin(): void {
    if (import.meta.env.PROD)
        window.location.href = "/login"
    else
        window.location.href = "http://localhost:3000/login"
}