pub fn symlink_path(enc_path: &str) -> Option<String> {
    let trimmed = enc_path.trim_end_matches('/');
    let last_slash = trimmed.rfind('/')?;
    let dir = &trimmed[..=last_slash];
    let base = &trimmed[last_slash + 1..];
    let lower = base.to_lowercase();
    if !lower.ends_with("encrypted") {
        return None;
    }
    let prefix = &base[..base.len() - "encrypted".len()];
    Some(format!("{dir}{prefix}decrypted"))
}
