function export_pdf_report(app, filename)
    import mlreportgen.dom.*;
    d = Document(filename, 'pdf');
    
    append(d, Paragraph('QCS Actuator Response Report'));
    append(d, Paragraph(sprintf('Date: %s', datestr(now))));
    append(d, Paragraph(sprintf('Actuator Width: %.1f bins (%.2f mm)', ...
        app.spnActuatorWidth.Value, app.spnActuatorWidth.Value * app.spnBinWidth.Value)));
    
    if ~isempty(app.LastSpatial)
        t = Table({{'Metric','Value'}; ...
            {'CoM (mm)', sprintf('%.3f', app.LastSpatial.cm_mm)}; ...
            {'FWHM (mm)', sprintf('%.3f', app.LastSpatial.width_mm)}; ...
            {'Gain (nm/bin)', sprintf('%.3f', app.LastSpatial.gain_nm_per_bin)}});
        append(d, t);
    end
    
    fig = figure('Visible','off');
    imagesc(app.CurrentMatrix); colorbar;
    title('Filtered CD Map');
    append(d, Figure(fig));
    close(fig);
    
    close(d);
end