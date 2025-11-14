function cb_export_pdf(src, ~, app)
    [file, path] = uiputfile('*.pdf');
    if isequal(file,0), return; end
    src.utils.export_pdf_report(app, fullfile(path,file));
    app.StatusText = 'PDF exported';
end