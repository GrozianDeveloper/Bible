//
//  BibleViewController+PageHandle.swift
//  Bible
//
//  Created by Bogdan Grozian on 28.02.2022.
//

import UIKit

// MARK: - UIPageViewControllerDelegate
extension BibleViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let chapterController = bookPageController.viewControllers?.first as? ChapterViewController else {
            return
        }
        activeChapterOffset = chapterController.chapterOffset
    }
}

// MARK: - UIPageViewControllerDataSource
extension BibleViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let chapterController = bookPageController.viewControllers?.first as? ChapterViewController,
                chapterController.chapterOffset > 0 else {
            return nil
        }
        let previous = pages[chapterController.chapterOffset - 1]
        return previous
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let chapterController = bookPageController.viewControllers?.first as? ChapterViewController,
                chapterController.chapterOffset < pages.count - 1 else  {
            return nil
        }
        let next = pages[chapterController.chapterOffset + 1]
        return next
    }
}
