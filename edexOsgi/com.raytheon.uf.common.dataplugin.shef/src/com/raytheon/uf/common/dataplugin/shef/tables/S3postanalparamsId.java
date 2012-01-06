/**
* This software was developed and / or modified by Raytheon Company,
* pursuant to Contract DG133W-05-CQ-1067 with the US Government.
* 
* U.S. EXPORT CONTROLLED TECHNICAL DATA
* This software product contains export-restricted data whose
* export/transfer/disclosure is restricted by U.S. law. Dissemination
* to non-U.S. persons whether in the United States or abroad requires
* an export license or other authorization.
* 
* Contractor Name:        Raytheon Company
* Contractor Address:     6825 Pine Street, Suite 340
*                         Mail Stop B8
*                         Omaha, NE 68106
*                         402.291.0100
* 
* See the AWIPS II Master Rights File ("Master Rights File.pdf") for
* further licensing information.
**/
package com.raytheon.uf.common.dataplugin.shef.tables;
// default package
// Generated Oct 17, 2008 2:22:17 PM by Hibernate Tools 3.2.2.GA

import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * S3postanalparamsId generated by hbm2java
 * 
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Oct 17, 2008                        Initial generation by hbm2java
 * Aug 19, 2011      10672     jkorman Move refactor to new project
 * 
 * </pre>
 * 
 * @author jkorman
 * @version 1.1
 */
@Embeddable
@javax.xml.bind.annotation.XmlRootElement
@javax.xml.bind.annotation.XmlAccessorType(javax.xml.bind.annotation.XmlAccessType.NONE)
@com.raytheon.uf.common.serialization.annotations.DynamicSerialize
public class S3postanalparamsId extends com.raytheon.uf.common.dataplugin.persist.PersistableDataObject implements java.io.Serializable, com.raytheon.uf.common.serialization.ISerializableObject {

    private static final long serialVersionUID = 1L;

    @javax.xml.bind.annotation.XmlElement
    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Short ggWeighting;

    @javax.xml.bind.annotation.XmlElement
    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Float ggMinGageVal;

    @javax.xml.bind.annotation.XmlElement
    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Short ggMinDist;

    @javax.xml.bind.annotation.XmlElement
    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Float kernelEstScale;

    @javax.xml.bind.annotation.XmlElement
    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Float rhat;

    public S3postanalparamsId() {
    }

    public S3postanalparamsId(Short ggWeighting, Float ggMinGageVal,
            Short ggMinDist, Float kernelEstScale, Float rhat) {
        this.ggWeighting = ggWeighting;
        this.ggMinGageVal = ggMinGageVal;
        this.ggMinDist = ggMinDist;
        this.kernelEstScale = kernelEstScale;
        this.rhat = rhat;
    }

    @Column(name = "gg_weighting")
    public Short getGgWeighting() {
        return this.ggWeighting;
    }

    public void setGgWeighting(Short ggWeighting) {
        this.ggWeighting = ggWeighting;
    }

    @Column(name = "gg_min_gage_val", precision = 8, scale = 8)
    public Float getGgMinGageVal() {
        return this.ggMinGageVal;
    }

    public void setGgMinGageVal(Float ggMinGageVal) {
        this.ggMinGageVal = ggMinGageVal;
    }

    @Column(name = "gg_min_dist")
    public Short getGgMinDist() {
        return this.ggMinDist;
    }

    public void setGgMinDist(Short ggMinDist) {
        this.ggMinDist = ggMinDist;
    }

    @Column(name = "kernel_est_scale", precision = 8, scale = 8)
    public Float getKernelEstScale() {
        return this.kernelEstScale;
    }

    public void setKernelEstScale(Float kernelEstScale) {
        this.kernelEstScale = kernelEstScale;
    }

    @Column(name = "rhat", precision = 8, scale = 8)
    public Float getRhat() {
        return this.rhat;
    }

    public void setRhat(Float rhat) {
        this.rhat = rhat;
    }

    public boolean equals(Object other) {
        if ((this == other))
            return true;
        if ((other == null))
            return false;
        if (!(other instanceof S3postanalparamsId))
            return false;
        S3postanalparamsId castOther = (S3postanalparamsId) other;

        return ((this.getGgWeighting() == castOther.getGgWeighting()) || (this
                .getGgWeighting() != null
                && castOther.getGgWeighting() != null && this.getGgWeighting()
                .equals(castOther.getGgWeighting())))
                && ((this.getGgMinGageVal() == castOther.getGgMinGageVal()) || (this
                        .getGgMinGageVal() != null
                        && castOther.getGgMinGageVal() != null && this
                        .getGgMinGageVal().equals(castOther.getGgMinGageVal())))
                && ((this.getGgMinDist() == castOther.getGgMinDist()) || (this
                        .getGgMinDist() != null
                        && castOther.getGgMinDist() != null && this
                        .getGgMinDist().equals(castOther.getGgMinDist())))
                && ((this.getKernelEstScale() == castOther.getKernelEstScale()) || (this
                        .getKernelEstScale() != null
                        && castOther.getKernelEstScale() != null && this
                        .getKernelEstScale().equals(
                                castOther.getKernelEstScale())))
                && ((this.getRhat() == castOther.getRhat()) || (this.getRhat() != null
                        && castOther.getRhat() != null && this.getRhat()
                        .equals(castOther.getRhat())));
    }

    public int hashCode() {
        int result = 17;

        result = 37
                * result
                + (getGgWeighting() == null ? 0 : this.getGgWeighting()
                        .hashCode());
        result = 37
                * result
                + (getGgMinGageVal() == null ? 0 : this.getGgMinGageVal()
                        .hashCode());
        result = 37 * result
                + (getGgMinDist() == null ? 0 : this.getGgMinDist().hashCode());
        result = 37
                * result
                + (getKernelEstScale() == null ? 0 : this.getKernelEstScale()
                        .hashCode());
        result = 37 * result
                + (getRhat() == null ? 0 : this.getRhat().hashCode());
        return result;
    }

}
