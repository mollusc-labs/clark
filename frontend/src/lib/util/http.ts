export const get = <T>(url: string): Promise<T> => {
    return fetch(url)
        .then(t => t.json())
        .catch(console.error)
}