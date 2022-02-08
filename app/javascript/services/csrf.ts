export function getCsrfToken(): string {
  return (
    (document.querySelector("meta[name=csrf-token]") as HTMLMetaElement)
      ?.content || ""
  );
}
