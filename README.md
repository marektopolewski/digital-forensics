# Digital Forensics

Digital forensics is the area of Computer Science which uses of scientific methods to collect probative facts from digital evidences. This repository includes my expoloration of only a subset of topics around the subject and focuses predominantly on **image analysis** and **video analysis**. Digital forensics is becoming an increasingly important aspect of IT due to the rise of fake content, hence, my keen interest in it.<br/>

## Structure
<br/>
<table>
  <tr>
    <th>Dir</th><th>Content</th>
  </tr>

  <tr>
    <td><code>set1/</code></td>
    <td>
        <table>
            <tr>
                <td><code>report.pdf</code></td>
                <td>Report containing tasks, explanations and results of the first set.</td>
            </tr>
            <tr>
                <td><code>scripts/</code></td>
                <td>Scripts used to solve tasks introduced in <code>set1/report.pdf</code>.<br/>
                    <table>
                        <tr><th>Task</th><th>Script</th><th>Function</th></tr>
                        <tr><td>1.1.</td><td><code>YCbConversion.m</code></td>
                            <td>Converts a RGB image to <b>YCbCr scale</b> and displays individual channels.</td>
                        </tr>
                        <tr><td>1.2.</td><td><code>YCbForensics.m</code></td>
                            <td>Determines suspect using <b>Chroma subsampling</b> analysis.</td>
                        </tr>
                        <tr><td>2.1.</td><td><code>colorEnhance.m</code></td>
                            <td>Enhance image adopting <b>histogram matching</b> in each RGB channel in pixel (spacial) domain.</td>
                        </tr>
                        <tr><td>2.2.</td><td><code>denoiseForensics.m</code></td>
                            <td>Remove repetitive spectral noise. Convert image to frequency domain and use a <b>notch filter</b>.</td>
                        </tr>
                        <tr><td>3.1.</td><td><code>watermarkPix.m</code></td></tr>
                        <tr><td>3.2.</td><td><code>watermarkFreq.m</code></td></tr>
                    </table>
                </td>
            </tr>
        </table>
    </td>
  </tr>

  <tr>
    <td><code>set2/</code></td>
    <td>
        <table>
            <tr>
                <td><code>report.pdf</code></td>
                <td>Report containing tasks, explanations and results of the second set.</td>
            </tr>
            <tr>
                <td><code>scripts/</code></td>
                <td>Scripts used to solve tasks introduced in <code>set2/report.pdf</code>.
                    <table>
                        <tr><td>1.1. <code>YCbConversion.m</code></td></tr>
                        <tr><td>1.2. <code>YCbForensics.m</code></td></tr>
                        <tr><td>2.1. <code>colorEnhance.m</code></td></tr>
                        <tr><td>2.2. <code>denoiseForensics.m</code></td></tr>
                        <tr><td>3.1. <code>watermarkPix.m</code></td></tr>
                        <tr><td>3.2. <code>watermarkFreq.m</code></td></tr>
                    </table>
                </td>
            </tr>
        </table>
    </td>
  </tr>
</table>
<br/>

## Contents
<br/>

| | **Image representation** |
| -- | -- |
| **YCbCr scale** | An alternative colour space to RGB which allows to seprate components of the image for luminance (brightness) - Y, and colour chroma (colour) - Cb and Cr. |
| **Chroma subsampling** | Subsampling allows to reduce the size of image's representation by reducing the number of pixels required to represent each Chroma channel. If the method can be reconstructed from an unidentified picture, then the camera sources can be narrowed to the ones utilising the given subsampling. The reconstruction is performed by subsampling the raw Y channel and comparing it (R2 similarity) with the already subsampled Chroma channels on a block-based basis. |
<br/>

| | **Image enhancement** |
| -- | -- |
| **Image histogram** | A discrete function which to each pixel intesity level assigns the number pixels having value in that level. If normalised, i.e. Y-axis represnts the ratio instead of the count, then the histogram can be treated as a probability mass distro (PMF). |
| **Histogram equalisation** | Given a histogram, turn it into a uniform PMF. Calculated by reassigning each `i` in `[0,N]` intesity level such that at each level the cumulative distribution is less or equal to `i/N`. This technique can be used to improve image's contrast. |
| **Histogram matching** | Generalisation to the equalisation. Instead of matching the uniform CDF, match to a CDF of a reference normalised histogram. |
| **Frequency domain** | A common method of converting an image from the spatial domain to the frequency domain uses the Discrete Cosine Transform (DCT). The pixmap is expressed as a weighted composition of a cosine waves with varying frequency. Lower frequencies represent uniform areas while higher frequencies indicate significant changes in pixel domain. The operation is invertible - Inverse DCT. |
| **Notch filter** | Given an image in the frequency domain, repetative noise in the pixel domain can be observed as unusually high values (peaks) in the higher frequencies. From those points and their neighbourhood, a mask is substracted (e.g. Gaussian). The frequencies must be selected ad-hoc. |