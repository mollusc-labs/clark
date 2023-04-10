import { error } from "./store"

export const httpErrorHandler = (t: any) => {
    console.error(t)
    error.value = t
}

export const get = <T>(url: string): Promise<T> => {
    return fetch(url)
        .then(t => t.json())
        .catch(httpErrorHandler)
}

export const post = <T>(url: string, body: any = undefined): Promise<T> => {
    return fetch(url, {
        headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        },
        method: 'POST',
        body: JSON.stringify(body)
    })
        .then(t => t.json())
        .catch(httpErrorHandler)
}