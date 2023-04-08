export const time = () => Math.floor(Date.now() / 1000)
export const convertTime = (time: Date) => Math.floor(time.getTime() / 1000)