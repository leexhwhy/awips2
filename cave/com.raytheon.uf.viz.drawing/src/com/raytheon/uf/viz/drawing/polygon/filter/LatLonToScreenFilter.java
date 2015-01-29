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
package com.raytheon.uf.viz.drawing.polygon.filter;

import com.raytheon.uf.viz.core.rsc.AbstractVizResource;
import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.CoordinateSequence;

/**
 * A CoordinateSequenceFilter that converts the CoordinateSequence's points from
 * a lat/lon CRS to the screen coordinates (ie SWT coordinates).
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * 
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Jan 26, 2015  3974      njensen     Initial creation
 * 
 * </pre>
 * 
 * @author njensen
 * @version 1.0
 */

public class LatLonToScreenFilter extends StatusCoordSequenceFilter {

    public LatLonToScreenFilter(AbstractVizResource<?, ?> display) {
        super(display);
    }

    @Override
    public void filter(CoordinateSequence seq, int i) {
        Coordinate c = seq.getCoordinate(i);
        double[] screen = getContainer().translateInverseClick(c);
        c.x = screen[0];
        c.y = screen[1];
    }

}
