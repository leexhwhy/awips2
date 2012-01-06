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
package com.raytheon.viz.core.graphing;

import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.Rectangle;

import com.raytheon.uf.viz.core.IGraphicsTarget;
import com.raytheon.uf.viz.core.IGraphicsTarget.LineStyle;
import com.vividsolutions.jts.geom.Coordinate;

/**
 * Implements a world coordinate to graphics viewport transform.
 * 
 * <pre>
 * SOFTWARE HISTORY
 * 
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * 06 Nov 2006             jkorman     Initial Coding
 * </pre>
 * 
 * @author jkorman
 * @version 1.0
 */
public class WGraphics {

    private double cursorX = 0;

    private double cursorY = 0;

    private double worldXmin = -1;

    /**
     * @return the worldXmin
     */
    public double getWorldXmin() {
        return worldXmin;
    }

    /**
     * @return the worldYmin
     */
    public double getWorldYmin() {
        return worldYmin;
    }

    /**
     * @return the worldXmax
     */
    public double getWorldXmax() {
        return worldXmax;
    }

    /**
     * @return the worldYmax
     */
    public double getWorldYmax() {
        return worldYmax;
    }

    private double worldYmin = 1;

    private double worldXmax = 1;

    private double worldYmax = -1;

    private double xk1;

    private double yk1;

    private double viewXmin;

    private double viewYmin;

    private double viewXmax;

    private double viewYmax;

    // private IGraphicsTarget graphicsContext;

    /** Default text color */
    private RGB textColor = new RGB(255, 255, 255);

    /**
     * Create a World coordinates graph
     * 
     * @param x1
     *            Upper left output x.
     * @param y1
     *            Upper left output y.
     * @param x2
     *            Lower right output x.
     * @param y2
     *            Lower right output y.
     * @param graphContext
     *            The graphics target that defines the output.
     */
    public WGraphics(double x1, double y1, double x2, double y2) {

        viewXmin = x1;
        viewYmin = y1;
        viewXmax = x2;
        viewYmax = y2;
        setCoordinateMapping();
    }

    public WGraphics(Rectangle rect) {
        this(rect.x, rect.y, rect.x + rect.width, rect.y + rect.height);
    }

    /**
     * Calculate the scaling factors for the x,y mapping.
     */
    private void setCoordinateMapping() {
        xk1 = (viewXmax - viewXmin) / (worldXmax - worldXmin);
        yk1 = (viewYmax - viewYmin) / (worldYmax - worldYmin);
    }

    public void setWorldCoordinates(double x1, double y1, double x2, double y2) {
        worldXmin = x1;
        worldYmin = y1;
        worldXmax = x2;
        worldYmax = y2;
        setCoordinateMapping();
    }

    /**
     * Map a world value to its viewport coordinate
     * 
     * @param x
     *            The world x value.
     * @return The viewport x value.
     */
    public double mapX(double x) {
        return viewXmin + (x - worldXmin) * xk1;
    } // mapX()

    /**
     * Map a world value to its viewport coordinate
     * 
     * @param y
     *            The world y value.
     * @return The viewport y value.
     */
    public double mapY(double y) {
        return viewYmin + (y - worldYmin) * yk1;
    } // mapY()

    /**
     * Map a world coordinate to its viewport coordinate
     * 
     * @param cIn
     *            the world coordinate
     * @return the viewport coordinate
     */
    public Coordinate map(Coordinate cIn) {
        Coordinate cOut = new Coordinate();

        cOut.x = mapX(cIn.x);
        cOut.y = mapY(cIn.y);

        return cOut;
    }

    /**
     * Take an viewport coordinate and map back to the corresponding world
     * coordinate values using the current view.
     * 
     * @param the
     *            viewport coordinate
     * @return the world coordinate
     */
    public Coordinate unMap(Coordinate cIn) {
        return unMap(cIn.x, cIn.y);
    }

    /**
     * Take an output x,y position and map back to the corresponding world
     * coordinate values using the current view.
     * 
     * @param xPos
     *            The viewport x value.
     * @param yPos
     *            The viewport y value.
     * @return The unmapped coordinate.
     */
    public Coordinate unMap(double xPos, double yPos) {
        Coordinate dataPoint = new Coordinate();

        dataPoint.x = ((xPos - viewXmin) / xk1) + worldXmin;
        dataPoint.y = ((yPos - viewYmin) / yk1) + worldYmin;

        return dataPoint;
    }

    /**
     * Move the drawing cursor to point x1, y1.
     * 
     * @param x1
     *            The world x value.
     * @param y1
     *            The world y value.
     */
    public void moveTo(double x, double y) {
        cursorX = mapX(x);
        cursorY = mapY(y);
    } // moveTo()

    /**
     * Draw to point x1, y1 using a specified color.
     * 
     * @param x1
     *            The world x value.
     * @param y1
     *            The world y value.
     * @param color
     *            The drawing color.
     */
    public void drawTo(IGraphicsTarget target, double x, double y, RGB color) {
        this.drawTo(target, x, y, color, LineStyle.SOLID);
    } // drawTo()

    public void drawTo(IGraphicsTarget target, double x, double y, RGB color,
            LineStyle lineStyle) {
        try {
            double mx = mapX(x);
            double my = mapY(y);
            target.drawLine(cursorX, cursorY, 0.0, mx, my, 0.0, color, 1,
                    lineStyle);
            cursorX = mx;
            cursorY = my;

        } catch (Exception e) {
            e.printStackTrace();
        }
    } // drawTo()

    public double getViewXmin() {
        return viewXmin;
    }

    public void setViewXmin(double viewX1) {
        this.viewXmin = viewX1;
    }

    public double getViewYmin() {
        return viewYmin;
    }

    public void setViewYmin(double viewY1) {
        this.viewYmin = viewY1;
    }

    public double getViewXmax() {
        return viewXmax;
    }

    public void setViewXmax(double viewX2) {
        this.viewXmax = viewX2;
    }

    public double getViewYmax() {
        return viewYmax;
    }

    public void setViewYmax(double viewY2) {
        this.viewYmax = viewY2;
    }
}
