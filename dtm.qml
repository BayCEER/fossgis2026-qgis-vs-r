<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Symbology|AttributeTable" version="3.42.0-Münster">
  <pipe-data-defined-properties>
    <Option type="Map">
      <Option type="QString" name="name" value=""/>
      <Option name="properties"/>
      <Option type="QString" name="type" value="collection"/>
    </Option>
  </pipe-data-defined-properties>
  <pipe>
    <provider>
      <resampling maxOversampling="2" zoomedInResamplingMethod="nearestNeighbour" zoomedOutResamplingMethod="nearestNeighbour" enabled="false"/>
    </provider>
    <rasterrenderer alphaBand="-1" classificationMin="322.2700195" nodataColor="" type="singlebandpseudocolor" band="1" classificationMax="593.3760376" opacity="1">
      <rasterTransparency/>
      <minMaxOrigin>
        <limits>MinMax</limits>
        <extent>WholeRaster</extent>
        <statAccuracy>Estimated</statAccuracy>
        <cumulativeCutLower>0.02</cumulativeCutLower>
        <cumulativeCutUpper>0.98</cumulativeCutUpper>
        <stdDevFactor>2</stdDevFactor>
      </minMaxOrigin>
      <rastershader>
        <colorrampshader minimumValue="322.27001949999999" maximumValue="593.37603760000002" clip="0" colorRampType="INTERPOLATED" classificationMode="1" labelPrecision="4">
          <colorramp type="cpt-city" name="[source]">
            <Option type="Map">
              <Option type="QString" name="inverted" value="0"/>
              <Option type="QString" name="rampType" value="cpt-city"/>
              <Option type="QString" name="schemeName" value="jjg/dem/c3t3"/>
              <Option type="QString" name="variantName" value=""/>
            </Option>
          </colorramp>
          <item color="#75b08d" label="322,2700" alpha="255" value="322.27001953125"/>
          <item color="#dcebc8" label="357,5138" alpha="255" value="357.5138018798833"/>
          <item color="#fffcc8" label="392,7576" alpha="255" value="392.75758422851663"/>
          <item color="#ffddaf" label="428,0014" alpha="255" value="428.0013665771499"/>
          <item color="#fccf9e" label="463,2451" alpha="255" value="463.2451489257832"/>
          <item color="#fbc28e" label="498,4889" alpha="255" value="498.4889312744165"/>
          <item color="#e4e8f4" label="533,7327" alpha="255" value="533.7327136230498"/>
          <item color="#d6e1f2" label="566,2654" alpha="255" value="566.265435791019"/>
          <item color="#d6e1f2" label="593,3760" alpha="255" value="593.37603759766"/>
          <rampLegendSettings useContinuousLegend="1" suffix="" prefix="" minimumLabel="" orientation="2" maximumLabel="" direction="0">
            <numericFormat id="basic">
              <Option type="Map">
                <Option type="invalid" name="decimal_separator"/>
                <Option type="int" name="decimals" value="6"/>
                <Option type="int" name="rounding_type" value="0"/>
                <Option type="bool" name="show_plus" value="false"/>
                <Option type="bool" name="show_thousand_separator" value="true"/>
                <Option type="bool" name="show_trailing_zeros" value="false"/>
                <Option type="invalid" name="thousand_separator"/>
              </Option>
            </numericFormat>
          </rampLegendSettings>
        </colorrampshader>
      </rastershader>
    </rasterrenderer>
    <brightnesscontrast brightness="0" gamma="1" contrast="0"/>
    <huesaturation grayscaleMode="0" saturation="0" invertColors="0" colorizeOn="0" colorizeRed="255" colorizeBlue="128" colorizeGreen="128" colorizeStrength="100"/>
    <rasterresampler maxOversampling="2"/>
    <resamplingStage>resamplingFilter</resamplingStage>
  </pipe>
  <blendMode>6</blendMode>
</qgis>
