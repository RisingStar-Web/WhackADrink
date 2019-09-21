
#define IS_IPAD					(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define rgb(r, g, b)			[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define degreesToRadians(x)		(M_PI * (x) / 180.0)

#define CircleIntersectsCircle(circle1, circle2) \
({ \
    CGFloat radius1 = circle1.size.width / 2; \
    CGFloat radius2 = circle2.size.width / 2; \
CGFloat aSq = (CGRectGetMidX(circle1) - CGRectGetMidX(circle2)) * (CGRectGetMidX(circle1) - CGRectGetMidX(circle2)); \
CGFloat bSq = (CGRectGetMidY(circle1) - CGRectGetMidY(circle2)) * (CGRectGetMidY(circle1) - CGRectGetMidY(circle2)); \
    CGFloat cSq = (radius1 + radius2) * (radius1 + radius2); \
    aSq + bSq <= cSq; \
})
