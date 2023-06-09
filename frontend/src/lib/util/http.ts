import { error } from "./store"
import type { ClarkError } from "../model/error"
import { redirectToLogin } from "./redirect"

const httpBodyBase = (method: string) => {
    return (url: string) => (body: any = undefined) =>
        fetch(url,
            {
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(body),
                method
            })
            .then(async t => {
                if (t.ok) {
                    return t.json()
                } else {
                    throw await t.json() as ClarkError;
                }
            })
            .catch(httpErrorHandler)
}

export const httpErrorHandler = (t: ClarkError) => {
    console.error(t)
    if (t.err === 401 || t.err === 403) {
        redirectToLogin()
    } else {
        error.value = t
    }
}

export const get = <T>(url: string): Promise<T> => {
    return fetch(url)
        .then(t => {
            if (t.ok) {
                return t.json()
            }

            throw { err: t.status, msg: t.statusText }
        })
        .catch(httpErrorHandler)
}

export const del = (url: string): Promise<void> => {
    return fetch(url, {
        method: 'DELETE'
    })
        .then(t => {
            if (!t.ok) {
                throw { err: t.status, msg: t.statusText }
            }
        })
        .catch(httpErrorHandler)
}



export const post = <T>(url: string, body: any = undefined): Promise<T> => {
    return httpBodyBase('POST')(url)(body)
}

export const put = <T>(url: string, body: any = undefined): Promise<T> => {
    return httpBodyBase('PUT')(url)(body)
}