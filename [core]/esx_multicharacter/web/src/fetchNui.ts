export async function fetchNui<T = any, R = any>(eventName: string, data?: T): Promise<R> {
  const resourceName = (window as any).GetParentResourceName ? (window as any).GetParentResourceName() : 'nui-resource';
  const resp = await fetch(`https://${resourceName}/${eventName}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JSON.stringify(data || {}),
  });
  if (!resp.ok) {
    throw new Error(`NUI callback failed: ${resp.status}`);
  }
  return await resp.json();
} 