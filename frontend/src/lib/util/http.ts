import { error } from "./store"
import type { ClarkError } from "../model/error";

const httpBodyBase = (method: string) => {
    return (url: string) => (body: any) =>
        fetch(url,
            {
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                method,
                body: JSON.stringify(body)
            })
            .then(async t => {
                if (t.ok) {
                    return t.json();
                } else {
                    throw await t.json() as ClarkError;
                }
            })
            .catch(httpErrorHandler);
}

export const httpErrorHandler = (t: ClarkError) => {
    console.error(t)
    error.value = t
}

export const get = <T>(url: string): Promise<T> => {
    return fetch(url)
        .then(t => t.json())
        .catch(httpErrorHandler)
}

export const post = <T>(url: string, body: any = undefined): Promise<T> => {
    return httpBodyBase('POST')(url)(body);
}

export const put = <T>(url: string, body: any = undefined): Promise<T> => {
    return httpBodyBase('PUT')(url)(body);
}