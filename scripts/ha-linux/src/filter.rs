use serde_json::{Map, Value};

/// Transform a HA state_changed event, or return `None` to drop it.
pub fn transform_event(event: &Value) -> Option<Value> {
    let data = event.get("data")?;
    let entity_id = data.get("entity_id")?.as_str()?.to_owned();

    let new_state = data.get("new_state")?;

    let attributes = new_state.get("attributes");
    let last_changed = new_state.get("last_changed");
    let last_updated = new_state.get("last_updated");
    let time_fired = event.get("time_fired");

    let mut map = Map::new();
    map.insert("entity_id".into(), Value::String(entity_id));

    if let Some(s) = new_state.get("state").and_then(|v| v.as_str()) {
        map.insert("state".into(), coerce_state_value(s));
    }

    if let Some(a) = attributes {
        map.insert("attributes".into(), a.clone());
    }
    if let Some(lc) = last_changed {
        map.insert("last_changed".into(), lc.clone());
    }
    if let Some(lu) = last_updated {
        map.insert("last_updated".into(), lu.clone());
    }
    if let Some(tf) = time_fired {
        map.insert("time_fired".into(), tf.clone());
    }

    Some(Value::Object(map))
}

/// Check if an entity_id matches a glob pattern (`*` and `?` wildcards).
pub fn entity_matches(pattern: &str, entity_id: &str) -> bool {
    let p = pattern.as_bytes();
    let s = entity_id.as_bytes();
    let (mut pi, mut si) = (0, 0);
    let (mut star, mut match_si) = (None, 0);

    while si < s.len() {
        if pi < p.len() && (p[pi] == b'?' || p[pi] == s[si]) {
            pi += 1;
            si += 1;
        } else if pi < p.len() && p[pi] == b'*' {
            star = Some(pi);
            match_si = si;
            pi += 1;
        } else if let Some(sp) = star {
            pi = sp + 1;
            match_si += 1;
            si = match_si;
        } else {
            return false;
        }
    }

    p[pi..].iter().all(|&b| b == b'*')
}

fn coerce_state_value(s: &str) -> Value {
    match s {
        "on" => Value::Bool(true),
        "off" => Value::Bool(false),
        _ => {
            if let Ok(n) = s.parse::<i64>() {
                Value::Number(n.into())
            } else if let Ok(n) = s.parse::<f64>() {
                if let Some(n) = serde_json::Number::from_f64(n) {
                    Value::Number(n)
                } else {
                    Value::String(s.to_owned())
                }
            } else {
                Value::String(s.to_owned())
            }
        }
    }
}
