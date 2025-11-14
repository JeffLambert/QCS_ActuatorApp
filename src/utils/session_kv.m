function varargout = session_kv(action, key, value)
    persistent store;
    if isempty(store), store = containers.Map; end
    switch action
        case 'set', store(key) = value;
        case 'get'
            if isKey(store, key)
                varargout{1} = store(key);
            else
                varargout{1} = [];
            end
    end
end